require_relative '../spec_helper'
require 'spectrum/mms_id'

describe Spectrum::MmsId do
  before(:each) do
    @doc_id = '333000555'
    @mms_id = '993330005550206381'
  end
  context "initialized mms_id" do
    subject do
      described_class.new(@mms_id)
    end
    it "exposes doc_id" do
      expect(subject.doc_id).to eq(@doc_id)
    end
    it "exposes prefix_code" do
      expect(subject.prefix_code).to eq('99')
    end
    it "exposes institution_code" do
      expect(subject.institution_code).to eq('6381')
    end
    it "exposes unique_id" do
      expect(subject.unique_id).to eq("#{@doc_id}020")
    end
    context "to_s" do
      it "returns appropriate mms_id" do
        ## leading 99 means physical item
        ## trailing 6381 is from umich
        expect(subject.to_s).to eq(@mms_id)
      end
    end
  end
end
