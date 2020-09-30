require_relative '../../spec_helper'
require 'rails'
require 'spectrum/json'

describe Spectrum::Response::Holdings, "integrations" do
  def stub_http(id:,getHoldings:,solr:)
    stub_request(:get, "http://localhost/solr/biblio/select?q=id:#{id}&wt=json").to_return(body: solr, status: 200, headers: {content_type: 'application/json'})
    stub_request(:get, "http://mirlyn/getHoldings.pl?id=#{id}").to_return(body: getHoldings, status: 200, headers: {content_type: 'application/json'})
  end
  before(:each) do
    
    #stubbing FloorLocation because don't want to load real data
    allow(Spectrum::FloorLocation).to receive(:resolve).and_return('5th Floor')

    #Spectrum::FloorLocation.configure('./spec/fixtures/floor_locations.json')
    #stubbing Aleph because loading it is hard
    allow(Aleph).to receive(:intent).and_return("success")
    allow(Aleph).to receive(:icon).and_return("check_circle")
    
    @source_dbl = double('Source', url: 'http://localhost/solr/biblio', holdings: 'http://mirlyn/getHoldings.pl?id=', driver: 'RSolr')

  end
  subject do
    described_class.new(@source_dbl, @request)
  end
  it "returns expected array for single normal holding" do
    @request = Spectrum::Request::Holdings.new({id: '000311635'}) 
    solr = File.read('./spec/fixtures/hurdy_solr.json')
    getHoldings = File.read('./spec/fixtures/hurdy_gurdy_getHoldings.json')
    stub_http(id: @request.id, getHoldings: getHoldings, solr: solr)

    output = JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_output.json'), symbolize_names: true)
    expect(subject.renderable).to eq(output)
  end
  it "returns expected array for uplinks" do
    @request = Spectrum::Request::Holdings.new({id: '005061252'}) 
    solr = File.read('./spec/fixtures/uplinks_solr.json')
    getHoldings = File.read('./spec/fixtures/uplinks_getHoldings.json')
    stub_http(id: @request.id, getHoldings: getHoldings, solr: solr)

    output = JSON.parse(File.read('./spec/fixtures/uplinks_output.json'), symbolize_names: true)
    expect(subject.renderable).to eq(output)
  end
  it "returns expected array for downlinks" do
    @request = Spectrum::Request::Holdings.new({id: '004759908'}) 
    solr = File.read('./spec/fixtures/downlinks_solr.json')
    getHoldings = File.read('./spec/fixtures/downlinks_getHoldings.json')
    stub_http(id: @request.id, getHoldings: getHoldings, solr: solr)

    output = JSON.parse(File.read('./spec/fixtures/downlinks_output.json'), symbolize_names: true)
    expect(subject.renderable).to eq(output)
  end
end
