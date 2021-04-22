module Spectrum
  class Holding
    def initialize(input)
      @input = input
      @holding = input.holding #holding element from getHoldings.pl
      @id = input.id
      @bib_record = input.bib_record
    end
    def self.for(input)
      if input.holding['up_links'] || input.holding['down_links']
        LinkedHolding.for(input)
      elsif input.holding['location'] == 'HathiTrust Digital Library'
        HathiTrustHolding.new(input)
      else
        MirlynHolding.new(input)
      end
    end

    def to_h
      {
         caption: caption,
         captionLink: captionLink,
         name: name,
         notes: notes,
         headings: headings,
         rows: rows,
         type: type
      }.delete_if { |k,v| v.nil? || v.empty? }
    end

    private
    def caption
        @holding['location']
    end
    def captionLink
      @holding['info_link'] ? {href: @holding['info_link'], text: 'About location'} : nil
    end
    def name
      nil
    end
    def type
      'physical'
    end
    def headings
      []
    end
    def rows
      []
    end
    def notes
      nil
    end
  end

  class Holding::MirlynHolding < Holding
    private
    def headings
      ['Action', 'Description', 'Status', 'Call Number']
    end
    def name
      'holdings'
    end
    def notes
      [
        @holding['public_note'],
        @holding['summary_holdings'],
        Spectrum::FloorLocation.resolve(
          @holding['sub_library'],
          @holding['collection'],
          @holding['callnumber']
        )
      ].compact.reject(&:empty?)
    end
    def rows
      @holding['item_info'].map { |item_info| Holding::MirlynItem.new(holding_input: @input, item_info: item_info).to_a }
    end
  end
  class Holding::HathiTrustHolding < Holding
    private
    def headings
      ['Link', 'Description', 'Source']
    end
    def type
      'electronic'
    end
    def name
      'HathiTrust Sources'
    end
    def rows
      @holding['item_info'].map { |info| process_item_info(info) }
    end
    def process_item_info(info)
      status = info['status']
      handle = "http://hdl.handle.net/2027/#{info['id']}"
      suffix = if status.include?('log in required')
        "?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth"
      else
        ''
      end
      [
        {text: status, href: "#{handle}#{suffix}"},
        {text: info['description'] || ''},
        {text: info['source'] || 'N/A'}
      ]
    end
  end
  class Holding::LinkedHolding < Holding
    def self.for(input)
      if input.holding['down_links']
        Holding::DownLinkedHolding.new(input)
      else
        Holding::UpLinkedHolding.new(input)
      end
    end

    private
    def headings
        ['Record link']
    end
    def name
      nil
    end

    def process_link(link)
      [
        {
          text: link['link_text'],
          to: {
            record: link['key'],
            datastore: @id,
          }
        }
      ]
    end
  end
  class Holding::DownLinkedHolding < Holding::LinkedHolding
    private
    def caption
      'Bound with'
    end
    def rows
      @holding['down_links'].map { |link| process_link(link) }
    end
  end
  class Holding::UpLinkedHolding < Holding::LinkedHolding
    private
    def caption
      'Included in'
    end
    def rows
      @holding['up_links'].map { |link| process_link(link) }
    end
  end
end
