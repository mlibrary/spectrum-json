#Will eventually be Holding, but need to deal with PlaceHold first. This goes with holdings method in JsonController
module Spectrum
  attr_reader :preExpanded
  class MyHolding
    def initialize(holding: {}, preExpanded: false)
      @holding = holding
      @preExpanded = preExpanded
    end

    def caption
    end

    def headings
    end
    def name
    end
    def rows
    end
    def type
      "pysical"
    end
  end
  class AlmaHolding < Spectrum::MyHolding
    def initialize(holding: {}, 
                   source:,
                   preExpanded: false, 
                   items: {}, 
                   collections_data: YAML.load_file(File.expand_path('../utility/collections.yml', __FILE__)), 
                   holding_record: MARC::XMLReader.new(StringIO.new(holding['anies']&.first || '')).first 
                  ) 
      @items = items
      @collections_data = collections_data 
      @holding_record = holding_record
      @source = source
      super(holding: holding, preExpanded: preExpanded)
    end
    def caption
      #Library Description?
      "#{library_name} #{location_name}".strip
    end
    def captionLink
      collection = @collections_data.find {|x| x["code"] == library_location_code}
      collection&.dig('lib_info_link') || ''
    end
    def headings
      [
        "Action",
        "Description",
        "Status",
        "Call Number"
      ]
    end
    def name
      "holdings"
    end
    def notes(floor_location = Spectrum::FloorLocation.resolve(library, location, call_number)) 

      [public_note, summary, floor_location].compact.reject(&:empty?)
    end
    def rows
    end
    #type: physical
    private
    
    def public_note
      collect_holding_info('852','z',', ')
    end
    
    def summary
     collect_holding_info('866','a',' : ')
    end
    
    def collect_holding_info(tag, code, seperator) 
      #get all 852 tagged fields
      tags = @holding_record.find_all{ |x| x.tag == tag}

      #filter only code z; flatten into one array
      codes = tags&.map{|x| x.find_all{|y| y.code==code} }&.flatten
      
      #format
      codes&.map{|x| x.value}&.join(seperator)
    end
    
    def call_number
      @items[0].dig("holding_data","call_number")
    end
    def library_name
      @items[0].dig("item_data","library","desc") || ''
    end
    def library
      @items[0].dig("item_data","library","value") || ''
    end
    def location_name
      location = @items[0].dig("item_data","location","desc") || ''
      location == 'Main' ? '' : location
    end
    def location
      location = @items[0].dig("item_data","location","value") || ''
      location == 'MAIN' ? '' : location
    end
    def library_location_code
      "#{library} #{location}".strip
    end

  end
  class AlmaItem 
    def initialize(item:{}, source:, spectrum_item: Spectrum::Item.new(item) )
      @raw = item
      @item = spectrum_item
      @source = source
    end
    def to_a(action: Spectrum::ItemAction.for( item: @item, source: @source ), 
              intent: Aleph.intent(item.status), icon: Aleph.icon(item.status))
      [
        action.to_h,
        {
          text: @item.status || 'N/A',
          intent: intent || 'N/A',
          icon: icon || 'N/A'
        },
        { text: call_number || 'N/A' }
      ]
    end
    private 
    def call_number
      if inventory_number and @item.call_number =~ /^VIDEO/
        [@item.call_number, inventory_number].join(' - ')
      elsif @item.call_number.empty?
        nil
      else
        @item.call_number
      end
    end
    def inventory_number
      number = @raw.dig('item_data', 'inventory_number')
      if number&.empty?
        nil
      else
        number
      end
    end
    def action
      if @item.can_request?
        {
          text: 'Get this',
          to: {
            barcode: @item.barcode,
            action: 'get-this',
            record: @item.record,
            datastore: @item.record
          }
        }
      else
        {text: 'N/A'}
      end
    end

  end
  class HathiHolding < Spectrum::MyHolding
    attr_reader :preExpanded
    def initialize(holding: {}, preExpanded: false, alma_client: Spectrum::Utility::AlmaClient.new)
      @alma_client = alma_client
      super(holding: holding, preExpanded: preExpanded)
      @holding.empty? ? @ph_exists = false : @ph_exists = get_ph_status
    end
    def caption
      "HathiTrust Digital Library"
    end
    def headings
      [
        "Link",
        "Description",
        "Source",
      ]
    end
    def name
      "HathiTrust Sources"
    end
    def type
      "electronic"
    end
    def print_holding?
      @ph_exists
    end
    def rows
      @holding["items"].map do |item|
        pick_item(item)
      end
    end
    def to_h
      {
        caption: caption,
        headings: headings,
        name: name,
        preExpanded: @preExpanded,
        rows: rows.map{ |r| r.to_a },
        type: type
      }
    end
    private
    def pick_item(item)
      if item['rightsCode'] =~ /^(pd|world|cc|und-world|ic-world)/
        PublicDomainHathiItem.new(item)
      elsif print_holding? || item['orig'] == 'University of Michigan'
        EtasHathiItem.new(item)
      else
        HathiItem.new(item)
      end
    end

    def get_ph_status
      oclcs = @holding["records"]&.values&.first&.dig("oclcs")
      oclcs.each do |oclc|
        response = @alma_client.get('/bibs',{query: {other_system_id: oclc, view: 'brief'}})
        if response.code == 200 && response.parsed_response["total_record_count"] > 0
          return true
        end
      end
      return false
    end
  end
  class HathiItem
    def initialize(item)
      @source = item['orig'] || 'N/A'
      @url = item['itemURL']
      @description = item['enumcron'] || 'N/A'
    end
    def to_a
      [
          {text: status, href: href},
          {text: @description},
          {text: @source}
      ]
    end

    private
    def href
      @url
    end
    def status
        "Search only (no full text)"
    end
  end
  class PublicDomainHathiItem < HathiItem
    def status
      "Full text"
    end
  end

  class EtasHathiItem < HathiItem
    def href
      "#{@url}?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth"
    end
    def status
      "Full text available, simultaneous access is limited (HathiTrust log in required)"
    end
  end
end
