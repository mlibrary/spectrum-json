module Spectrum::Entities
  class Holdings
    attr_reader :holdings, :doc_id
    def initialize(data)
      @doc_id = data.keys.first
      @holdings = data[@doc_id].map { |h| Holding.for(@doc_id, h) } 
    end
    def self.for(source, request)
      response = HTTParty.get("#{source.holdings}#{request.id}")
      if response.code == 200
        Holdings.new(response.parsed_response)
      else
        []
      end
    end
    def [](index)
      @holdings[index]
    end
    def each(&block)
      @holdings.each(&block)
    end
    def find_item(barcode)
      items = mirlyn_holdings.map{|x| x.items }.flatten
      item = items.find {|x| x.barcode == barcode }
      item ? item : EmptyItem.new
    end
    private
    def mirlyn_holdings
      @holdings.filter{|x| x.class.name.to_s.match(/MirlynHolding/) }
    end
  end

  class Holding
    attr_reader :doc_id
    def initialize(doc_id, data)
      @doc_id = doc_id
      @data = data
    end
    def self.for(doc_id, data)
      if data['location'] == 'HathiTrust Digital Library'
        HathiHolding.new(doc_id, data)
      else
        MirlynHolding.new(doc_id, data)
      end
    end
    def items
      @data["item_info"].map{|x| GetHoldingsItem.for(self, x) }
    end

    def callnumber
      @data["callnumber"]
    end
    def sub_library
      @data["sub_library"]
    end
    def collection
      @data["collection"]
    end
    def info_link
      @data["info_link"]
    end
    def location
      @data["location"]
    end
    def status
      @data["status"]
    end
  end
  class MirlynHolding < Holding
    def holding_id
      @data["hol_doc_number"]
    end
    def up_links
      @data["up_links"]
    end
    def down_links
      @data["down_links"]
    end
    def public_note
      @data["public_note"]
    end
    def summary_holdings
      @data["summary_holdings"]
    end
  end
  class HathiHolding < Holding
    def id
      @data["id"]
    end
  end
  class GetHoldingsItem
    extend Forwardable
    def_delegators :@holding, :doc_id, :callnumber, :sub_library, :collection, :holding_id, :id
    def initialize(holding, item)
      @holding = holding
      @item = item
    end
    def record
      doc_id
    end
    def self.for(holding, item)
      if holding.class.name.to_s =~ /Hathi/
        HathiItem.new(holding, item)
      else
        MirlynItem.new(holding, item)
      end
    end
    def raw
      @item
    end
    def description
      @item['description'] || ''
    end
    def status
      @item["status"]
    end
  end
  class MirlynItem < GetHoldingsItem
    def barcode
      @item["barcode"]
    end
    def can_book?
      @item["can_book"]
    end
    def can_request?
      @item['can_request'] ||
        ['HSRS', 'HERB', 'MUSM'].include?(sub_library)
    end
    def can_reserve?
      @item["can_reserve"]
    end
    def full_item_key
      @item["full_item_key"]
    end

    def inventory_number
      @item['inventory_number']
    end
    def item_process_status
      @item['item_process_status']
    end
    def item_expected_arrival_date
      @item['item_expected_arrival_date']
    end
    def item_status
      @item['item_status']
    end
    def issue
      @item['description'] || ''
    end
    def notes
      @item['description'] || ''
    end
    def temp_location?
      @item['temp_location'] 
    end
    def temp_location
      @item['temp_loc'] || ''
    end

  end
  class HathiItem < GetHoldingsItem
    def source
      @item["source"]
    end
    def rights
      @item["rights"]
    end
  end
  class EmptyItem
    def can_book?; false end
    def can_reserve?; false end
    def can_request?; false end
    def status; '' end
    def location; '' end
  end
end
