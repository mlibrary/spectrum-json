describe Spectrum::Entities::AlmaItem do
  subject do
    response = JSON.parse(File.read('./spec/fixtures/alma_one_holding.json'))
    holding = instance_double(Spectrum::Entities::AlmaHolding, title: "title")
    described_class.new(holding: holding, item: response["item"][0]["item_data"], full_item: response["item"][0])
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
  it "has an inventory_number" do
    expect(subject.inventory_number).to eq("")
  end
  it "returns temp_location status" do
    expect(subject.temp_location?).to eq(false)
  end
  it "returns a description" do
    expect(subject.description).to eq("")
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
