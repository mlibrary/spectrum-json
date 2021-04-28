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
      Spectrum::Entities::AlmaHolding.new(bib: @bib, holding: holding_data, items: items)
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

  def initialize(bib:, holding:, items:)
    @bib = bib
    @holding = holding
    @items = items.map{|x| Spectrum::Entities::AlmaItem.new(holding: self, item: x)}
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
class Spectrum::Entities::AlmaItem
  extend Forwardable
  def_delegators :@holding, :mms_id, :title, :author, 
    :issn, :isbn, :pub_date, :callnumber, :holding_id
  def initialize(holding:, item:)
    @holding = holding
    @item = item
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
end
