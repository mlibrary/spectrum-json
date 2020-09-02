require_relative '../spec_helper'
require 'spectrum/my_holding'
require 'spectrum/utility/alma_client'

describe Spectrum::AlmaHolding do
  it "returns appropriate heading" do
    holding = described_class.new
    expect(holding.headings).to eq(["Action","Description","Status","Call Number"])
  end
end

describe Spectrum::HathiHolding do
  context "default holding" do
    subject do
      described_class.new
    end
    it "returns appropriate heading" do
      expect(subject.headings).to eq(["Link","Description","Source"])
    end
    it "returns appropriate caption" do
      expect(subject.caption).to eq("HathiTrust Digital Library")
    end
    it "returns appropriate name" do
      expect(subject.name).to eq("HathiTrust Sources")
    end
    it "returns appropriate type" do
      expect(subject.type).to eq("electronic")
    end
  end
  context 'one item HathiTrust Holding' do
    before(:each) do
      @alma_response = JSON.parse(File.read('./spec/fixtures/alma_has_oclc.json'))
      @resp_dbl = double('HTTParty::Response', parsed_response: @alma_response, code: 200 )
      @alma_double = double('Spectrum::Utility::AlmaClient',get: @resp_dbl )
      @hathi_response = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
    end
    describe "to_h" do
      it "returns appropriate hash" do
        expected_hathi_holding_response= JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_output.json'), symbolize_names: true)[0]
        hathi_holding = described_class.new(holding: @hathi_response, alma_client: @alma_double)
        expect(hathi_holding.to_h).to eq(expected_hathi_holding_response)
      end
    end
    describe "preExpanded" do
      it "returns true when initialized with preExpanded true" do
        hathi_holding = described_class.new(holding: @hathi_response, preExpanded: true, alma_client: @alma_double)
        expect(hathi_holding.preExpanded).to eq(true)
      end
      it "returns false when initialized with preExpanded false" do
        hathi_holding = described_class.new(holding: @hathi_response, preExpanded: false, alma_client: @alma_double)
        expect(hathi_holding.preExpanded).to eq(false)
      end
      it "returns false by default" do
        hathi_holding = described_class.new(holding: @hathi_response, alma_client: @alma_double)
        expect(hathi_holding.preExpanded).to eq(false)
      end
    end
    describe "rows" do
      it "returns array of EtasHathiItems for ic print holding" do
        hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        expect(hathi_item.rows.first.class.name).to eq("Spectrum::EtasHathiItem")
      end
      it "returns array of HathiItems when not in umich catalogue" do
        allow(@resp_dbl).to receive(:parsed_response).and_return({'total_record_count' => 0})
        hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        expect(hathi_item.rows.first.class.name).to eq("Spectrum::HathiItem")
      end
      it "returns array of PublicDomainHathiItems when not in umich catalogue" do
        @hathi_response["items"][0]["rightsCode"] = 'pd'
        hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        expect(hathi_item.rows.first.class.name).to eq("Spectrum::PublicDomainHathiItem")
      end
    end
    describe "print_holding?" do
      it "calls alma_client with oclc value" do
        expect(@alma_double).to receive(:get).with("/bibs", {query: {other_system_id: "10543709", view: 'brief'}})
        described_class.new(holding: @hathi_response,alma_client: @alma_double)
      end
      it "returns true if oclc found in alma" do
        hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        expect(hathi_item.print_holding?).to eq(true)
      end
      it "returns false if oclc not found" do
        allow(@resp_dbl).to receive(:parsed_response).and_return({'total_record_count' => 0})
        hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        expect(hathi_item.print_holding?).to eq(false)
      end
      it "returns false if receives response error" do
        allow(@resp_dbl).to receive(:code).and_return(400)
        hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        expect(hathi_item.print_holding?).to eq(false)
      end
    end
  end
end
describe Spectrum::HathiItem, "to_a" do
  subject do
    hathi_resp = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
    described_class.new(hathi_resp['items'].first)
  end
  it "returns appropriate array" do
    expected_output = [
      {text: "Search only (no full text)", href: "https://hdl.handle.net/2027/inu.30000042758924",},
      {text: 'N/A'},
      {text: 'Indiana University'}
    ]
    expect(subject.to_a).to eq(expected_output)
  end
end
describe Spectrum::PublicDomainHathiItem, "to_a" do
  subject do
    hathi_resp = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
    described_class.new(hathi_resp['items'].first)
  end
  it "returns appropriate array" do
    expected_output = [
      {text: "Full text", href: "https://hdl.handle.net/2027/inu.30000042758924",},
      {text: 'N/A'},
      {text: 'Indiana University'}
    ]
    expect(subject.to_a).to eq(expected_output)
  end
end
describe Spectrum::EtasHathiItem, "to_a" do
  subject do
    hathi_resp = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
    described_class.new(hathi_resp['items'].first)
  end
  it "returns appropriate array" do
    expected_output = [
      {text: "Full text available, simultaneous access is limited (HathiTrust log in required)", href: "https://hdl.handle.net/2027/inu.30000042758924?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth",},
      {text: 'N/A'},
      {text: 'Indiana University'}
    ]
    expect(subject.to_a).to eq(expected_output)
  end
end
