require 'alma_rest_client'
class Spectrum::Entities::AlmaHoldings
  attr_reader :holdings
  def initialize(alma:, solr:)
    @alma = alma
    @solr = solr #Spectrum::BibRecord
    @holdings = load_holdings
  end
  def self.for(bib_record:, client: AlmaRestClient.client)
    if bib_record.physical_holdings?
      #response = client.get_all(url: "/bibs/#{bib_record.mms_id}/holdings/ALL/items", record_key: "item")
      #if response.code == 200
        #Spectrum::Entities::AlmaHoldings.new(alma: response.parsed_response, solr: bib_record)
        Spectrum::Entities::AlmaHoldings.new(alma: nil, solr: bib_record)
      #else
        #TBD ERROR
      #end
    else
      Spectrum::Entities::AlmaHoldings::Empty.new
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
    false
  end
  
  private
  def load_holdings
    #holdings = {}
    #@alma["item"].each do |x|
    #  holding_id = x["holding_data"]["holding_id"]
    #  holdings[holding_id] = [] if holdings[holding_id].nil?
    #  holdings[holding_id].push(x)
    #end

    @solr.alma_holdings.map do |solr_holding|
  
      #alma_holding = holdings[solr_holding.holding_id]
      Spectrum::Entities::AlmaHolding.new(bib: @solr, full_items: nil, solr_holding: solr_holding)
    end
  end
  
end
class Spectrum::Entities::AlmaHoldings::Empty
  def holdings
    []
  end
  def empty?
    true
  end
end
class Spectrum::Entities::AlmaHolding
  attr_reader :items, :bib_record, :solr_holding
  extend Forwardable
  def_delegators :@bib_record, :mms_id, :doc_id, :title, :author, 
    :issn, :isbn, :pub_date
  def initialize(bib:, full_items: [], solr_holding: nil )
    @bib_record = bib #now is solr BibRecord

    @solr_holding = solr_holding
    @items = solr_holding.items.map do |solr_item|
      #alma_item = full_items.find{|alma_item| alma_item["item_data"]["pid"] == solr_item.id}
      Spectrum::Entities::AlmaItem.new(holding: self, solr_item: solr_item, alma_item: {},
                                      bib_record: @bib_record)
    end
  end
  def holding_id
    @solr_holding.holding_id
  end
  def callnumber
    @solr_holding.callnumber
  end
  def public_note
    @solr_holding.public_note
  end
  def summary_holdings
    @solr_holding.summary_holdings
  end
  def location_text
    Spectrum::LibLocDisplay.text(library, location) 
  end
  def location_link
    Spectrum::LibLocDisplay.link(library, location) 
  end
   
  def library
    @solr_holding.library
  end
  def location
    @solr_holding.location
  end
end
