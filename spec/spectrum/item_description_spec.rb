require_relative '../spec_helper'
require 'spectrum/item_description'
require 'spectrum/item'

describe Spectrum::ItemDescription do
  context "to_h" do
    before(:each) do
      @item_dbl = instance_double(Spectrum::Item, description: nil, in_temp_location?: false, full_temp_location_name: '')
    end
    subject do
      described_class.new(item: @item_dbl).to_h
    end
    it "returns default of 'N/A'" do
      expect(subject).to eq({text: 'N/A'})
    end
    it "returns only description" do
      allow(@item_dbl).to receive(:description).and_return('description')
      expect(subject).to eq({text: 'description'})
    end
    it "returns only temp location" do
      allow(@item_dbl).to receive(:in_temp_location?).and_return(true)
      allow(@item_dbl).to receive(:full_temp_location_name).and_return('MyTempLocation')
      expect(subject).to eq({text: 'Temporary location: Shelved at MyTempLocation'})
    end
    it "returns description and temp location" do
      allow(@item_dbl).to receive(:in_temp_location?).and_return(true)
      allow(@item_dbl).to receive(:full_temp_location_name).and_return('MyTempLocation')
      allow(@item_dbl).to receive(:description).and_return('description')
      expect(subject).to eq({html: '<div>description</div><div>Temporary location: Shelved at MyTempLocation</div>'})
    end
  end

end

