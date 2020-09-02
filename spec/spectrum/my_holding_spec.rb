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
    it "shows appropriate prexpanded for single item but also in Alma"
    it "has appropriate rows"
    describe "print_holding?" do
      it "calls alma_client with oclc value" do
        expect(@alma_double).to receive(:get).with("/bibs", {query: {other_system_id: "10543709", view: 'brief'}})
        described_class.new(@hathi_response,@alma_double)
      end
      it "returns true if oclc found in alma" do
        hathi_item = described_class.new(@hathi_response,@alma_double)
        expect(hathi_item.print_holding?).to eq(true)
      end
      it "returns false if oclc not found" do
        allow(@resp_dbl).to receive(:parsed_response).and_return({'total_record_count' => 0})
        hathi_item = described_class.new(@hathi_response,@alma_double)
        expect(hathi_item.print_holding?).to eq(false)
      end
      it "returns false if receives response error" do
        allow(@resp_dbl).to receive(:code).and_return(400)
        hathi_item = described_class.new(@hathi_response,@alma_double)
        expect(hathi_item.print_holding?).to eq(false)
      end
    end
  end
end
