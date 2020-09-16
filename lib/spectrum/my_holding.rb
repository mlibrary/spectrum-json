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
      "physical"
    end

    def to_h
      {}
    end
    
  end
  class AlmaHolding < Spectrum::MyHolding
    def initialize(holding: {}, 
                   bib:, #Spectrum::BibRecord
                   preExpanded: false, 
                   items: {}, #array of alma items for a given holding
                   collections_data: YAML.load_file(File.expand_path('../utility/collections.yml', __FILE__)), 
                   holding_record: MARC::XMLReader.new(StringIO.new(holding['anies']&.first || '')).first 
                  ) 
      @items = items
      @collections_data = collections_data 
      @holding_record = holding_record
      @bib = bib
      super(holding: holding, preExpanded: preExpanded)
    end
    def caption
      #Library Description?
      "#{library_name} #{location_name}".strip
    end
    def captionLink
      collection = @collections_data.find {|x| x["code"] == library_location_code}
      link = collection&.dig('lib_info_link')
      link ? { href: link, text: "About location"} : nil
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
    def rows( almaItemFactory = lambda{|item, bib| AlmaItem.new(item: item, bib: bib)} )
      @items.map{ |item| almaItemFactory.call(item, @bib).to_a }
    end

    def to_h(almaItemFactory = lambda{|item, bib| AlmaItem.new(item: item, bib: bib)}, floor_location = Spectrum::FloorLocation.resolve(library, location, call_number))
      {
        caption: caption,
        captionLink: captionLink,
        headings: headings,
        name: name,
        notes: notes(floor_location),
        preExpanded: @preExpanded,
        rows: rows(almaItemFactory),
        type: type
      }.delete_if do |key,value| 
        next if key == :preExpanded
        value.nil? || value.empty? 
      end
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
    def initialize(item:{}, bib:, spectrum_item: Spectrum::Item.new(item) )
      @raw = item #Raw alma response
      @item = spectrum_item
      @bib = bib #Spectrum::BibRecord
    end
    def to_a(action: Spectrum::ItemAction.for( item: @item, bib: @bib ), 
             description: Spectrum::ItemDescription.new(item: @item),
              intent: Aleph.intent(item.status), icon: Aleph.icon(item.status))
      [
        action.to_h,
        description.to_h,
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

  end
  class HathiHolding < Spectrum::MyHolding
    attr_reader :preExpanded
    def initialize(holding: {}, preExpanded: false, alma_client: Spectrum::Utility::AlmaClient.new)
      @alma_client = alma_client
      #holding is hathi api response json
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
    def rows(hathi_item_factory = 
             lambda{|item, ph_exists| HathiItem.for(item: item, ph_exists: ph_exists) } 
            )
      @holding["items"].map { |item| hathi_item_factory.call(item, @ph_exists) }
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
      #item is HathiTrust json response for single item
      @source = item['orig'] || 'N/A'
      @url = item['itemURL']
      @description = item['enumcron'] || 'N/A'
    end
    def self.for(item:, ph_exists:,
                 pd_item_factory: lambda{|item| PublicDomainHathiItem.new(item)},
                 etas_item_factory: lambda{|item| EtasHathiItem.new(item)},
                 hathi_item_factory: lambda{|item| HathiItem.new(item)}
                )
      if item['rightsCode'] =~ /^(pd|world|cc|und-world|ic-world)/
        pd_item_factory.call(item)
      elsif ph_exists || item['orig'] == 'University of Michigan'
        etas_item_factory.call(item)
      else
        hathi_item_factory.call(item)
      end
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
