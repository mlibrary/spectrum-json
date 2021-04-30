require_relative '../../spec_helper'
describe Spectrum::Entities::CombinedHoldings do

  let(:mms_id) {'990020578280206381'}
  let(:solr_url) { 'http://localhost/solr/biblio' }

  before(:each) do
    @solr_bib_alma = JSON.parse(File.read('./spec/fixtures/solr_bib_alma.json'))

    @alma_holding_dbl1 = instance_double(Spectrum::Entities::AlmaHolding)
    @alma_holding_dbl2 = instance_double(Spectrum::Entities::AlmaHolding)
    @alma_holdings_dbl = instance_double(Spectrum::Entities::AlmaHoldings, 
        holdings: [@alma_holding_dbl1, @alma_holding_dbl2])
    
    @hathi_holding_dbl = instance_double(Spectrum::Entities::NewHathiHolding)
  end
  context ".for" do
    it "returns combined holdings" do
      solr_req = stub_request(:get, "#{solr_url}/select?q=id:#{mms_id}&wt=json").to_return(body: @solr_bib_alma.to_json, status: 200, headers: {content_type: 'application/json'})

    alma_req = stub_alma_get_request(url: "bibs/#{mms_id}/holdings/ALL/items", output: File.read('./spec/fixtures/alma_one_holding.json'), query: {limit: 100, offset: 0})
    expect(described_class.for(mms_id, solr_url).class).to eq(described_class)
      expect(solr_req).to have_been_requested
      expect(alma_req).to have_been_requested
    end
  end
  subject do 
    described_class.new(alma_holdings: @alma_holdings_dbl, hathi_holding: @hathi_holding_dbl ) 
  end
  it "has #hathi_holdings" do
    expect(subject.hathi_holdings).to eq([@hathi_holding_dbl])
  end
  it "has holdings" do
    expect(subject.holdings.count).to eq(3)
  end
  it "has working #each" do
    count = 0
    subject.each{|x| count = count + 1}
    expect(count).to eq(3)
  end
  it "has working empty?" do
    expect(subject.empty?).to eq(false)
  end
  it "has working []" do
    expect(subject[0]).to eq(@hathi_holding_dbl)
    expect(subject[1]).to eq(@alma_holding_dbl1)
    expect(subject[2]).to eq(@alma_holding_dbl2)
  end
  it "uses alma_holdings #find_item" do
    allow(@alma_holdings_dbl).to receive(:find_item).and_return('item')
    expect(subject.find_item('barcode')).to eq('item')
  end
end
