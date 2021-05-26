#TBD #status, #temp_location?
class Spectrum::Entities::AlmaItem
  extend Forwardable
  def_delegators :@holding, :mms_id, :doc_id, :title, 
    :author, :issn, :isbn, :pub_date, :holding_id
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
  def in_place?
    !!@item["base_status"]
  end
  def item_policy
    @item.dig("item_policy","value")
  end
  def item_policy_text
    @item.dig("item_policy","desc")
  end
  def requested?
    @item["requested"]
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
  def location
    @item.dig("location","value")
  end
  def inventory_number
    @item["inventory_number"]
  end
  def description
    @item["description"]
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
