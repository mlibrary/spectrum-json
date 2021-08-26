#TBD #status, #temp_location?
class Spectrum::Entities::AlmaItem
  extend Forwardable
  def_delegators :@holding, :holding_id, :public_note

  def_delegators :@bib_record, :mms_id, :doc_id, :etas?, :title, :author, 
    :restriction, :edition, :physical_description, :date, :pub, :place, 
    :publisher, :pub_date, :issn, :isbn, :genre, :sgenre, :finding_aid

  def_delegators :@solr_item, :callnumber, :temp_location?, :barcode, :library,
    :location, :permanent_library, :permanent_location, :description, :item_policy,
    :process_type, :inventory_number, :can_reserve?, :item_id, :record_has_finding_aid,
    :item_location_text, :item_location_link

  def initialize(holding:, alma_loan: nil, solr_item:, bib_record:)
    @holding = holding #AlmaHolding
    @alma_loan = alma_loan #parsed_response
    @solr_item = solr_item #BibRecord::AlmaHolding::Item
    @bib_record = bib_record #BibRecord
  end
  def pid
    @solr_item.id
  end
  def process_type
    if !@alma_loan.nil?
      'LOAN'
    elsif @solr_item.process_type == 'LOAN'
      #if Solr still says there's a loan, but alma doesn't have a loan for the item
      nil
    else
      @solr_item.process_type
    end
  end
  
  def due_date
    @alma_loan&.dig("due_date")
  end

  def in_reserves?
    ['CAR','OPEN','RESI','RESP','RESC','ERES'].include?(@solr_item.location)
  end
  
end
