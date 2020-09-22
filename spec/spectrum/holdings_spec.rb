require_relative '../spec_helper'
require 'spectrum/holdings'
require 'spectrum/request/holdings'
require 'spectrum/my_holding'
require 'spectrum/bib_record'
require 'spectrum/utility/alma_client'
require 'spectrum/utility/hathi_client'
require 'spectrum/floor_location'
require 'spectrum/item'
require 'spectrum/item_action'
require 'spectrum/item_description'


describe Spectrum::Holdings, "integrations" do
  before(:each) do
    #stubbing FloorLocation because don't want to load real data
    allow(Spectrum::FloorLocation).to receive(:resolve).and_return('5th Floor')

    #Spectrum::FloorLocation.configure('./spec/fixtures/floor_locations.json')
    #stubbing Aleph because loading it is hard
    allow(Aleph).to receive(:intent).and_return("success")
    allow(Aleph).to receive(:icon).and_return("check_circle")
    @source_dbl = double('Source', url: 'http://localhost/solr/biblio')

    stub_request(:get, 'http://localhost/solr/biblio/select?q=id:990003116350206381&wt=json').to_return(body: File.read('./spec/fixtures/hurdy_solr.json'), status: 200, headers: {content_type: 'application/json'})
    stub_request(:get, 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs/990003116350206381/holdings').to_return(body: File.read('./spec/fixtures/hurdy_gurdy_alma_holdings.json'), status: 200, headers: {content_type: 'application/json'})
    stub_request(:get, 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs/990003116350206381/holdings/22162173320006381').to_return(body: File.read('./spec/fixtures/hurdy_gurdy_alma_holding.json'), status: 200, headers: {content_type: 'application/json'})
    stub_request(:get, 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs/990003116350206381/holdings/22162173320006381/items').to_return(body: File.read('./spec/fixtures/hurdy_gurdy_alma_item.json'), status: 200, headers: {content_type: 'application/json'})
    stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/oclc/06961296").to_return(body: File.read('./spec/fixtures/hurdy_hathi.json'), status: 200, headers: {content_type: 'application/json'})

    @request = Spectrum::Request::Holdings.new({id: '990003116350206381'}) 

    @output = JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_output.json'), symbolize_names: true)

  end
  subject do
    described_class.new(source: @source_dbl, request: @request)
  end
  it "returns expected array" do
    expect(subject.to_a).to eq(@output)
  end
end

describe Spectrum::Holdings do
  before(:each) do
    @alma_holding_dbl = instance_double(Spectrum::AlmaHolding, caption: 'Askwith Media Library', to_h: {caption: 'Askwith Media Library'})
    @hathi_holding_dbl = instance_double(Spectrum::HathiHolding, caption: 'HathiTrust Digital Library', to_h: {caption: 'HathiTrust Digital Library'})

    @alma_parsed_response = {"total_record_count" => 1, "holding" => [{"holding_id" => '1234'}]}
    @alma_response_dbl = double('Response', code: 200, parsed_response: @alma_parsed_response)

    @hathi_response = instance_double(Spectrum::Utility::HathiResponse, empty?: false)


    @init = {
      source: nil,
      request: instance_double(Spectrum::Request::Holdings, id: 'mms_id'),
      client: instance_double(Spectrum::Utility::AlmaClient, get: @alma_response_dbl),
      bib_record: instance_double(Spectrum::BibRecord, oclc: [], physical_only?: true),
      alma_holding_factory: lambda {|holding, items, preExpanded, bib| @alma_holding_dbl },
      hathi_client: instance_double(Spectrum::Utility::HathiClient, get: @hathi_response),
      hathi_holding_factory: lambda {|holding, preExpanded| @hathi_holding_dbl },
    }
  end
  context "to_a" do
    subject do
      described_class.new(**@init).to_a
    end
    it "returns an array" do
      expect(subject.class.name).to eq('Array') 
    end
    it "shows Hathi Item" do
      expect(subject[0][:caption]).to eq('HathiTrust Digital Library')
    end
    it "shows Hathi Item" do
      expect(subject[1][:caption]).to eq('Askwith Media Library')
    end
  end
  context "holdings" do
    subject do
      described_class.new(**@init).holdings
    end
    it "returns an array of Hathi and Alma Holdings" do
      expect(subject[0]).to eq(@hathi_holding_dbl)
      expect(subject[1]).to eq(@alma_holding_dbl)
    end
    it "handles multiple Alma holdings" do
      @alma_parsed_response["holding"].push({"holding_id" => "56789"})
      expect(subject.count).to eq(3)
    end
    it "handles empty Hathi Holding" do
      allow(@hathi_response).to receive(:empty?).and_return(true)
      expect(subject.count).to eq(1)
    end
  end

  context "preExpanded" do
    subject do
      described_class.new(**@init).preExpanded
    end
    it "is false when physical only and hathi + alma > 1" do
      expect(subject).to eq(false)
    end 
    it "is true when physical only and only one hathi item" do
      @alma_parsed_response["total_record_count"] = 0
      expect(subject).to eq(true)
    end
    it "is true when physical only and only one alma item" do
      allow(@hathi_response).to receive(:empty?).and_return(true)
      expect(subject).to eq(true)
    end
    it "is false when not physical only" do
      allow(@init[:bib_record]).to receive(:physical_only?).and_return(false)
      @alma_parsed_response["total_record_count"] = 0
      expect(subject).to eq(false)
    end
  end
end
