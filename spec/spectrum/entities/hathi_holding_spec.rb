describe Spectrum::Entities::NewHathiHolding do
  before(:each) do
    @solr_bib_alma = JSON.parse(File.read('./spec/fixtures/solr_bib_alma.json'))
  end
  subject do
    described_class.new(Spectrum::BibRecord.new(@solr_bib_alma))
  end
  ['callnumber', 'sub_library', 'collection'].each do |method|
    context "#{method}" do
      it "has an empty #{method}" do
        expect(subject.public_send(method)).to eq('')
      end
    end
  end
  it "has a nil info_link" do
    expect(subject.info_link).to be_nil
  end
  it "has a doc_id" do
    expect(subject.doc_id).to eq('990020578280206381')

  end
  it "has a location" do
    expect(subject.location).to eq("HathiTrust Digital Library")
  end
  it "has items" do
    expect(subject.items.class.name.to_s).to  eq('Array')
  end
  context "#id" do
    
    it "has an id of first item if there is only one item" do
      expect(subject.id).to eq('mdp.39015017893416')
    end
    it "returns nil if there are multiple items" do
      holdings = @solr_bib_alma["response"]["docs"][0]["hol"]
      parsed_hol = JSON.parse(holdings)
      parsed_hol[1]["items"].push({})
      @solr_bib_alma["response"]["docs"][0]["hol"] = parsed_hol.to_json
      expect(subject.id).to be_nil
    end
  end

end
describe Spectrum::Entities::NewHathiItem do
  before(:each) do
    @solr_bib_alma = File.read('./spec/fixtures/solr_bib_alma.json')
  end
  subject do
    bib_record = Spectrum::BibRecord.new(JSON.parse(@solr_bib_alma))
    Spectrum::Entities::NewHathiHolding.new(bib_record).items.first
  end
  it "has a description" do
    expect(subject.description).to eq('')
  end
  it "has a source" do
    expect(subject.source).to eq('University of Michigan')
  end
  it "has rights" do
    expect(subject.rights).to eq('ic')
  end
  it "has a record" do
    expect(subject.record).to eq('990020578280206381')
  end
end
