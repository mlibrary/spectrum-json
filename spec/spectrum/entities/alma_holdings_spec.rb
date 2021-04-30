require_relative '../../spec_helper'
describe Spectrum::Entities::AlmaHoldings do
  before(:each) do
    @mms_id = "990020578280206381"
    stub_alma_get_request(url: "bibs/#{@mms_id}/holdings/ALL/items", output: File.read('./spec/fixtures/alma_one_holding.json'), query: {limit: 100, offset: 0})
  end
  subject do
    described_class.new(@mms_id)
  end
  it "has a bib" do
    expect(subject.bib.class.to_s).to eq("Spectrum::Entities::AlmaBib")
  end
  it "has working [] access" do
    expect(subject[0].class.name.to_s).to include('AlmaHolding')
  end
  it "returns holdings for #each" do
    holdings = []
    subject.each{|x| holdings.push(x.class.name.to_s) }
    expect(holdings[0]).to include('AlmaHolding')
  end
  it "has holdings" do
    expect(subject.holdings.first.class.to_s).to eq("Spectrum::Entities::AlmaHolding")
  end
  context "#find_item" do
    it "finds an item for a given barcode" do
      expect(subject.find_item("39015017893416").class.name.to_s).to eq("Spectrum::Entities::AlmaItem")
    end
    it "returns nil if barcode doesn't match" do
      expect(subject.find_item("not_a_barcode")).to be_nil
    end
  end
end
describe Spectrum::Entities::AlmaBib do
  subject do
    response = JSON.parse(File.read('./spec/fixtures/alma_one_holding.json'))
    described_class.new(response["item"][0]["bib_data"])
  end
  it "has an mms_id" do
    expect(subject.mms_id).to eq('990020578280206381')
  end
  it "has an title" do
    expect(subject.title).to eq('Enhancing faculty careers : strategies for development and renewal /')
  end
  it "has an author" do
    expect(subject.author).to eq('Schuster, Jack H.')
  end
  it "has an issn" do
    expect(subject.issn).to eq(nil)
  end
  it "has an isbn" do
    expect(subject.isbn).to eq('1555422101')
  end
  it "has an pub_date" do
    expect(subject.pub_date).to eq('1990.')
  end
end
describe Spectrum::Entities::AlmaHolding do
  before(:each) do
    Spectrum::LibLocDisplay.configure('spec/fixtures/lib_loc_display.json')
  end
  subject do
    response = JSON.parse(File.read('./spec/fixtures/alma_one_holding.json'))
    bib = instance_double(Spectrum::Entities::AlmaBib, title: "title")
    described_class.new(bib: bib, holding: response["item"][0]["holding_data"], items: [response["item"][0]["item_data"]])
  end
  it "has bib title" do
    expect(subject.title).to eq("title")
  end
  it "has holding_id" do
    expect(subject.holding_id).to eq("2297537770006381")
  end
  it "has location_text" do
    expect(subject.location_text).to eq("Hatcher Graduate")
  end
  it "has location_link" do
    expect(subject.location_link).to eq("http://www.lib.umich.edu/location/hatcher-graduate-library/unit/25")
  end
  it "has a call number" do
    expect(subject.callnumber).to eq("LB 2331.72 .S371 1990")
  end
  it "has items" do
    expect(subject.items[0].class.to_s).to eq('Spectrum::Entities::AlmaItem')
  end
end
describe Spectrum::Entities::AlmaItem do
  subject do
    response = JSON.parse(File.read('./spec/fixtures/alma_one_holding.json'))
    holding = instance_double(Spectrum::Entities::AlmaHolding, title: "title")
    described_class.new(holding: holding, item: response["item"][0]["item_data"])
  end
  it "has a bib title" do
    expect(subject.title).to eq("title")
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
end
