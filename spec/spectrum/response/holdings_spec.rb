require_relative '../../spec_helper'

require 'aleph'
require 'rsolr'
require 'rails'

require 'spectrum/response/holdings'
require 'spectrum/floor_location'
require 'spectrum/request/holdings'
require 'spectrum/bib_record'
require 'spectrum/holding/action'
require 'spectrum/holding/get_this_action'

describe Spectrum::Response::Holdings, "integrations" do
  before(:each) do
    @request = Spectrum::Request::Holdings.new({id: '000311635'}) 
    
    #stubbing FloorLocation because don't want to load real data
    allow(Spectrum::FloorLocation).to receive(:resolve).and_return('5th Floor')

    #Spectrum::FloorLocation.configure('./spec/fixtures/floor_locations.json')
    #stubbing Aleph because loading it is hard
    allow(Aleph).to receive(:intent).and_return("success")
    allow(Aleph).to receive(:icon).and_return("check_circle")
    
    @source_dbl = double('Source', url: 'http://localhost/solr/biblio', holdings: 'http://mirlyn/getHoldings.pl?id=', driver: 'RSolr')

    stub_request(:get, "http://localhost/solr/biblio/select?q=id:#{@request.id}&wt=json").to_return(body: File.read('./spec/fixtures/hurdy_solr.json'), status: 200, headers: {content_type: 'application/json'})
    stub_request(:get, "http://mirlyn/getHoldings.pl?id=#{@request.id}").to_return(body: File.read('./spec/fixtures/hurdy_gurdy_getHoldings.json'), status: 200, headers: {content_type: 'application/json'})



    @output = JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_output.json'), symbolize_names: true)

  end
  subject do
    described_class.new(@source_dbl, @request)
  end
  it "returns expected array" do
    expect(subject.renderable).to eq(@output)
  end
end
