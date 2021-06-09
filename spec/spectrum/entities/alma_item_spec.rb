require_relative '../../spec_helper'
describe Spectrum::Entities::AlmaItem do
  let(:solr_bib_record) do
    solr_bib_alma = JSON.parse(File.read('./spec/fixtures/solr_bib_alma.json'))
    Spectrum::BibRecord.new(solr_bib_alma)
  end
  subject do
    response = JSON.parse(File.read('./spec/fixtures/alma_one_holding.json'))
    solr_holding = solr_bib_record.alma_holding("2297537770006381")
    solr_item = solr_holding.items.first

    holding = instance_double(Spectrum::Entities::AlmaHolding, holding_id: "holding_id", bib_record: solr_bib_record, solr_holding: solr_holding)

    described_class.new(holding: holding,  alma_item: response["item"][0], solr_item: solr_item, bib_record: solr_bib_record)
  end
  it "has a bib title" do
    expect(subject.title).to eq("Enhancing faculty careers : strategies for development and renewal /")
  end
  it "has a callnumber" do
    expect(subject.callnumber).to eq('LB 2331.72 .S371 1990')
  end
  it "has a pid" do
    expect(subject.pid).to eq("2397537760006381")
  end
  it "has a barcode" do
    expect(subject.barcode).to eq("39015017893416")
  end
  it "has a library" do
    expect(subject.library).to eq("HATCH")
  end
  it "has a location" do
    expect(subject.location).to eq("GRAD")
  end
  it "has an inventory_number" do
    expect(subject.inventory_number).to eq(nil)
  end
  it "returns temp_location status" do
    expect(subject.temp_location?).to eq(false)
  end
  it "returns a description" do
    expect(subject.description).to eq(nil)
  end
  it "returns a process type" do
    expect(subject.process_type).to eq(nil)
  end
  it "calculates etas" do
    expect(subject.etas?).to eq(true)
  end
  
  context "#status" do
    it "handles it"
  end
  context "#can_request?" do
    it "handles it"
  end
  context "#can_reserve?" do
    it "handles it"
  end
  context "#can_book?" do
    it "handles it"
  end
  context "#item_process_status" do
    it "handles it"
  end
  context "#item_status" do
    it "handles it"
  end
  #in book_this_action; Do we even need this?
  context "#full_item_key" do
    it "handles it"
  end

end
