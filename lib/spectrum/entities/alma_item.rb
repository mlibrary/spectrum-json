#TBD #status, #temp_location?
class Spectrum::Entities::AlmaItem
  extend Forwardable
  def_delegators :@holding, :holding_id

  def_delegators :@bib_record, :mms_id, :doc_id, :etas?, :title, :author, 
    :restriction, :edition, :physical_description, :date, :pub, :place, 
    :publisher, :pub_date, :issn, :isbn, :genre, :sgenre

  def_delegators :@solr_item, :callnumber, :temp_location?, :barcode, :library,
    :location, :permanent_library, :permanent_location, :description, :item_policy,
    :process_type, :inventory_number, :can_reserve?

  def initialize(holding:, alma_loan: {}, solr_item:, bib_record:)
    @holding = holding #AlmaHolding
    @alma_loan = alma_loan #parsed_response
    @solr_item = solr_item #BibRecord::AlmaHolding::Item
    @bib_record = bib_record #BibRecord
  end
  def pid
    @solr_item.id
  end
  
  def due_date
    @alma_loan&.dig("due_date")
  end
  
  ##TBD
  #def can_request?
  #end
  ##TBD
  #def can_reserve?
  #end
  ##TBD
  #def can_book?
  #end
  #def item_process_status
  #end
  #def item_status
  #end
end
