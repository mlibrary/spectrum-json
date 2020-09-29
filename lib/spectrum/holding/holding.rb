module Spectrum
  class Holding
    def initialize(input)
      @holding = input.holding #holding element from getHoldings.pl
      @id = input.id
      @bib_record = input.bib_record
      #@preExpanded: false #state of preExpanded.
    end
    def self.for(input)
      if input.holding['up_links'] || input.holding['down_links']
        LinkedHolding.for(input)
      elsif input.holding['location'] == 'HathiTrust Digital Library'
        HathiTrustHolding.new(input)
      else
        Holding.new(input)
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
    def headings
      ['Action', 'Description', 'Status', 'Call Number']
    end
    def rows
      @holding['item_info'].map { |info| process_item_info(info) }
    end
    def type
      'physical'
    end



    def process_item_info(info)
      [
        get_action(info),
        get_description(info),
        {
          text: info['status'] || 'N/A',
          intent: Aleph.intent(info['status']) || '',
          icon: Aleph.icon(info['status'] || '')
        },
        {text: get_callnumber(info)  || 'N/A' }
      ]
    end
    def get_action(info)
      return Spectrum::Holding::Action.new(@id, @id, @bib_record, @holding, info).finalize
    end
    def get_callnumber(info)
      return nil unless (callnumber = info['callnumber'])
      return callnumber unless (inventory_number = info['inventory_number'])
      return callnumber unless callnumber.start_with?('VIDEO')
      [callnumber, inventory_number].join(' - ')
    end
    def get_description(info)
      if info['description'].nil? || info['description'].empty?
        if @holding['temp_loc'].nil? || @holding['temp_loc'].empty?
          {text: 'N/A'}
        else
          {text: "Temporary location: Shelved at #{@holding['temp_loc']}"}
        end
      else
        if @holding['temp_loc'].nil? || @holding['temp_loc'].empty?
          {text: info['description']}
        else
          {html: "<div>#{info['description']}</div><div>Temporary location: Shelved at #{@holding['temp_loc']}</div>"}
        end
      end
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
    def notes
      nil
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
        {text: info['description'] || 'N/A'},
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
    def notes
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
