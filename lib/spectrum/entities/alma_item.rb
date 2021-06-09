#TBD #status, #temp_location?
class Spectrum::Entities::AlmaItem
  extend Forwardable
  def_delegators :@holding, :holding_id
  def_delegators :@bib_record, :mms_id, :doc_id, :title, 
    :author, :issn, :isbn, :pub_date, :etas?
  def_delegators :@solr_item, :callnumber, :temp_location?, :barcode, :library,
    :location, :permanent_library, :permanent_location, :description, :item_policy,
    :process_type
  def initialize(holding:, alma_item:, solr_item:)
    @holding = holding #AlmaHolding
    @holding_raw = alma_item["holding_data"]
    @alma_item = alma_item["item_data"]
    @solr_item = solr_item
    @bib_record = holding.bib_record
  end
  def in_place?
    !!@alma_item["base_status"]
  end
  #def requested?
    #@alma_item["requested"]
  #end
  def pid
    @solr_item.id
  end
  #used in action
  def sub_library
    library
  end
  #used in get_this_action
  def collection
    location
  end
  #uesed in book_this_action
  def full_item_key
  end
  def inventory_number
    @alma_item["inventory_number"]
  end
  #TBD
  def status
  end
  
  #TBD
  def can_request?
  end
  #TBD
  def can_reserve?
  end
  #TBD
  def can_book?
  end
  def item_process_status
  end
  def item_status
  end
end
