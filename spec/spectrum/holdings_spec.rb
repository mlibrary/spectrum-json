require_relative '../spec_helper'
require 'spectrum/holdings'
require 'spectrum/my_holding'
require 'spectrum/bib_record'
require 'spectrum/utility/alma_client'
require 'spectrum/utility/hathi_holding_fetcher'


describe Spectrum::Holdings do
  before(:each) do
    @alma_holding_dbl = instance_double(Spectrum::AlmaHolding, caption: 'Askwith Media Library', to_h: {caption: 'Askwith Media Library'})
    @hathi_holding_dbl = instance_double(Spectrum::HathiHolding, caption: 'HathiTrust Digital Library', to_h: {caption: 'HathiTrust Digital Library'})

    @alma_parsed_response = {"total_record_count" => 1, "holding" => [{"holding_id" => '1234'}]}
    @alma_response_dbl = double('Response', code: 200, parsed_response: @alma_parsed_response)

    @hathi_response = {"records" => {}, "items" => [{"foo" => "bar"}]}

    @init = {
      source: nil,
      mms_id: 'mms_id',
      client: instance_double(Spectrum::Utility::AlmaClient, get: @alma_response_dbl),
      bib_record: instance_double(Spectrum::BibRecord, oclc: [], physical_only?: true),
      alma_holding_factory: lambda {|holding, items, preExpanded| @alma_holding_dbl },
      hathi_fetcher: instance_double(Spectrum::Utility::HathiHoldingFetcher, get: @hathi_response),
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
      @hathi_response["items"].shift
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
      @hathi_response["items"].shift
      expect(subject).to eq(true)
    end
    it "is false when not physical only" do
      allow(@init[:bib_record]).to receive(:physical_only?).and_return(false)
      @alma_parsed_response["total_record_count"] = 0
      expect(subject).to eq(false)
    end
  end
end
