# frozen_string_literal: true

require 'marc'
require 'rsolr'

module Spectrum
  class BibRecord
    SCANABLE = Hash.new(true).merge(
      'ISSCF' => false,
      'ISSMU' => false,
      'ISSVM' => false,
      'ISSMX' => false,
      'CF' => false,
      'MU' => false,
      'VM' => false,
      'MX' => false,
    )

    def self.fetch(id:, url:, rsolr_client_factory: lambda{|url| RSolr.connect(url: url)}, escaped_id: RSolr.solr_escape(id))
      client = rsolr_client_factory.call(url)
      BibRecord.new(client.get('select', params: { q: "id:#{escaped_id}"}))
    end
    def initialize(solr_response)
      @data = extract_data(solr_response)
      @fullrecord = MARC::XMLReader.new(StringIO.new(@data['fullrecord'])).first
    end
    def mms_id
      @data["id"]
    end

    def title
      (@fullrecord['245'] || []).select do |subfield|
        /[abdefgknp]/ === subfield.code
      end.map(&:value).join(' ')
    end

    def restriction
      (@fullrecord['506'] || []).select do |subfield|
        /[abc]/ === subfield.code
      end.map(&:value).join(' ')
    end

    def callnumber
      fetch_first('callnumber')
    end

    def issn
      candidate = fetch_first('issn')
      if candidate.empty? && fetch_first('isbn').empty?
        'N/A'
      else
        candidate
      end
    end

    def isbn
      fetch_first('isbn')
    end

    def edition
      fetch_first('edition')
    end

    def author
      fetch_joined('mainauthor', '; ')
    end

    def accession_number
      "<accession_number>#{fetch_joined('oclc', ',')}</accession_number>"
    end

    def date
      fetch_marc('260', 'c')
    end

    def pub
      fetch_marc('260', 'b')
    end

    def place
      fetch_marc('260', 'a')
    end

    def pub_date
      fetch_marc('245', 'f')
    end

    def publisher
      (@fullrecord['260'] || []).select do |subfield|
        /[abc]/ === subfield.code
      end.map(&:value).join(' ')
    end

    def physical_description
      clean_marc((@fullrecord['300'] || []).select do |subfield|
        /[abcf]/ === subfield.code
      end.map(&:value).join(' '))
    end

    def genre
      {
        'BK' => 'Book',
        'SE' => 'Serial Publication',
        'MP' => 'Map',
        'MU' => 'Music',
        'VM' => 'Visual Material',
        'MV' => 'Mixed Material`',
        'MX' => 'Mixed Material'
      }[fmt]
    end

    def sgenre
      {
        'BK' => 'Book',
        'SE' => 'Book',
        'MP' => 'Map',
        'MU' => 'Graphics',
        'VM' => 'Graphics',
        'MV' => 'Manuscripts',
        'MX' => 'Manuscripts'
      }[fmt]
    end

    def fmt
      (@fullrecord['970'] || { 'a' => '' })['a']
    end

    def physical_only?
      @fullrecord.fields('856').map { |field| field['u'] }.compact.empty?
    end

    def holdings
      JSON.parse(@data["hol"]).map{|x| Holding.for(x)}
    end
    def hathi_holding
      holdings.find{|x| x.class.name.to_s.match(/HathiHolding/) }
    end
    def alma_holding(holding_id)
      holdings.find{|x| x.holding_id == holding_id }
    end
    

    class Holding
      def initialize(holding)
        @holding = holding
      end
      def holding_id
        ''
      end
      def library
        @holding["library"]
      end
      def self.for(holding)
        if holding["library"] == "HathiTrust Digital Library"
          HathiHolding.new(holding)
        else
          AlmaHolding.new(holding)
        end
      end
    end
    class HathiHolding < Holding
      def items
        @holding["items"].map{|x| Item.new(x) }
      end
      class Item
        def initialize(item)
          @item = item
        end
        ["id", "rights", "description", "collection_code",
         "access", "source", "status"].each do |name|
          define_method(name) do
            @item[name]
          end
        end
      end
      private_constant :Item
    end
    class AlmaHolding  < Holding
      def holding_id 
        @holding["hol_mmsid"]
      end
      def location
        @holding["location"]
      end
      def callnumber
        @holding["callnumber"]
      end
      def public_note
        @holding["public_note"]
      end
      def summary_holdings
        @holding["summary_holdings"]
      end
      def items
        @holding["items"].map{|x| Item.new(x)}
      end
      
      class Item
        def initialize(item)
          @item = item
        end
        def id
          @item["item_id"]
        end
        def description
          @item["description"]
        end
        def public_note
          @item["public_note"]
        end
        def library
          @item["library"]
        end
        def location
          @item["location"]
        end
        def barcode
          @item["barcode"]
        end
      end

      private_constant :Item
    end

    private_constant :Holding, :AlmaHolding
    private

    def fetch_marc(datafield, subfield)
      clean_marc(((@fullrecord || {})[datafield] || {})[subfield] || '')
    end

    def extract_data(solr_response)
      solr_response['response']['docs'].first
    end

    def fetch_first(key)
      fetch_list(key).first || ''
    end

    def fetch_joined(key, string = ', ')
      fetch_list(key).join(string)
    end

    def fetch_list(key)
      Array(@data[key])
    end

    def clean_marc(str)
      str.respond_to?(:sub) ? str.sub(/[.,;:\/]$/, '') : ''
    end

    def etas?
      @fullrecord.any? do |field|
        field.tag == '973' && field.subfields.any? do |subfield|
          subfield.code == 'a' && subfield.value == 'ET'
        end
      end
    end

    def not_etas?
      !etas?
    end

    def formats
      @fullrecord.fields('970').map { |field| field['a'] }
    end

    def can_scan?
      return formats.all? { |format| SCANABLE[format] }
    end
  end
end
