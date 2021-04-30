require 'alma_rest_client'
class Spectrum::Entities::AlmaHoldings
  attr_reader :bib, :holdings
  def initialize(mms_id, client = AlmaRestClient.client)
    response = client.get_all(url: "/bibs/#{mms_id}/holdings/ALL/items", record_key: "item")
    if response.code == 200
      @parsed_response = response.parsed_response
      @bib = Spectrum::Entities::AlmaBib.new(@parsed_response["item"][0]["bib_data"])
      @holdings = load_holdings
    else
      #TBD ERROR
    end
  end

  def find_item(barcode)
    @holdings.map{|h| h.items}
      .flatten
      .find{|i| i.barcode == barcode}
  end

  def [](index)
    @holdings[index]
  end
  
  def each(&block)
    @holdings.each(&block)
  end
  def empty?
    @holdings.empty?
  end
  
  private
  def load_holdings
    holdings = {}
    @parsed_response["item"].each do |x|
      holding_id = x["holding_data"]["holding_id"]
      holdings[holding_id] = [] if holdings[holding_id].nil?
      holdings[holding_id].push(x)
    end
    holdings.values.map do |bib_hold_items|
      items = bib_hold_items.map{|x| x["item_data"] } 
      holding_data = bib_hold_items[0]["holding_data"]
      Spectrum::Entities::AlmaHolding.new(bib: @bib, holding: holding_data, items: items, holding_items: bib_hold_items)
    end
      
  end
  
end
class Spectrum::Entities::AlmaBib
  def initialize(bib)
    @bib = bib
  end
  def mms_id
    @bib["mms_id"]
  end
  def title
    @bib["title"]
  end
  def author
    @bib["author"]
  end
  def issn
    @bib["issn"]
  end
  def isbn
    @bib["isbn"]
  end
  def pub_date
    @bib["date_of_publication"]
  end
end
class Spectrum::Entities::AlmaHolding
  attr_reader :items
  extend Forwardable
  def_delegators :@bib, :mms_id, :title, :author, 
    :issn, :isbn, :pub_date

  #TBD 
  #public_note is in bib_record_holdings; 
  #summary_holdings; ???? 
  def initialize(bib:, holding:, items:, holding_items: [])
    @bib = bib
    @holding = holding_items[0]["holding_data"]
    @items = holding_items.map{|x| Spectrum::Entities::AlmaItem.new(holding: self, item: x["item_data"], full_item: x)}
  end
  def holding_id
    @holding["holding_id"]
  end
  def callnumber
    @holding["call_number"]
  end
  def location_text
    Spectrum::LibLocDisplay.text(library, location) 
  end
  def location_link
    Spectrum::LibLocDisplay.link(library, location) 
  end
   
  def library
    @items.first&.library
  end
  def location
    @items.first&.location
  end
end
#TBD #status, #temp_location?
class Spectrum::Entities::AlmaItem
  extend Forwardable
  def_delegators :@holding, :mms_id, :title, :author, 
    :issn, :isbn, :pub_date, :holding_id
  def initialize(holding:, item:, full_item:{})
    @holding = holding
    @holding_raw = full_item["holding_data"]
    @item = full_item["item_data"]
  end
  def callnumber
    @holding_raw["call_number"]
  end
  def temp_location?
    @holding_raw["in_temp_location"]
  end
  def temp_library
    @holding_raw.dig("temp_library","desc")
  end
  def temp_location
    @holding_raw.dig("temp_location","desc")
  end
  def pid
    @item["pid"]
  end
  def barcode
    @item["barcode"]
  end
  def library
    @item.dig("library","value")
  end
  def location
    @item.dig("location","value")
  end
  def inventory_number
    @item["inventory_number"]
  end
end
