require_relative '../../spec_helper'
require 'spectrum/utility/hathi_client'

describe Spectrum::Utility::HathiClient do
  before(:each) do
    @onkyu =  JSON.parse(File.read('./spec/fixtures/onkyu_hathi.json')) 
    @httparty_resp_dbl = double('HTTParty::Response', code: 200, parsed_response: @onkyu)
    @resolver_dbl = instance_double(Spectrum::Utility::HathiResolver, get: @httparty_resp_dbl)
  end
  it "only calls HTTParty.get once when oclcs included in early responses" do
    oclcs = @onkyu["records"].values.first["oclcs"]
    expect(@resolver_dbl).to receive(:get).once
    described_class.new(@resolver_dbl).get(oclcs)
  end
  context "integration" do
    it "given array of oclc it returns an appropriate HathiResponse" do
      stub_request(:get, 'https://catalog.hathitrust.org/api/volumes/brief/oclc/10543709').to_return(body: File.read('./spec/fixtures/hurdy_hathi.json'), status: 200, headers: {content_type: 'application/json'}) 
      resp = described_class.new.get(['10543709'])
      expect(resp.oclcs.count).to eq(4)
      expect(resp.items.count).to eq(1)
    end
  end


end

describe Spectrum::Utility::HathiResponse do
  before(:each) do
    @hurdy_hathi_response =JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json')) 
    @empty_response = {"records" => {}, "items" => []}
    @nmichigan_hathi_response = JSON.parse(File.read('./spec/fixtures/northern_michigan_hathi.json')) 
  end
  context "one entry response" do
    subject do
      described_class.new([@hurdy_hathi_response])
    end
    context "oclcs" do
      it "returns array of oclcs" do
        hurdy_hathi_oclcs = [ "10543709", "6961296", "60082813", "1008222435" ]
        expect(subject.oclcs).to eq(hurdy_hathi_oclcs)
      end
    end
    context "items" do
      it "returns array of items" do
        expect(subject.items).to eq(@hurdy_hathi_response["items"])
      end
    end
  end
  context "multiple empty responses" do
    subject do
      described_class.new([@empty_response, @empty_response])
    end
    context "oclcs" do
      it "returns array of oclcs" do
        expect(subject.oclcs).to eq([])
      end
    end
    context "items" do
      it "returns array of items" do
        expect(subject.items).to eq([])
      end
    end
  end
  context "multiple identical entry responses" do
    subject do
      described_class.new([@hurdy_hathi_response, @hurdy_hathi_response])
    end
    context "oclcs" do
      it "returns array of oclcs" do
        hurdy_hathi_oclcs = [ "10543709", "6961296", "60082813", "1008222435" ]
        expect(subject.oclcs).to eq(hurdy_hathi_oclcs)
      end
    end
    context "items" do
      it "returns array of items" do
        expect(subject.items).to eq(@hurdy_hathi_response["items"])
      end
    end
  end
  context "multiple different responses" do
    subject do
      described_class.new([@hurdy_hathi_response, @nmichigan_hathi_response])
    end
    context "oclcs" do
      it "returns array of oclcs" do
        hathi_oclcs = [ "10543709", "6961296", "60082813", "1008222435", "5997332" ]
        expect(subject.oclcs).to match_array(hathi_oclcs)
      end
    end
    context "items" do
      it "returns array of items" do
        expect(subject.items.count).to eq(10)
      end
    end
  end
  context "#empty?" do
    it "returns true if empty" do
      expect(described_class.new([@empty_response]).empty?).to eq(true)
    end
    it "returns false if not empty" do
      expect(described_class.new([@hurdy_hathi_response]).empty?).to eq(false)
    end
  end
end
