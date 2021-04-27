require_relative '../../spec_helper'
require 'spectrum/json'

describe Spectrum::Holding::MirlynItemDescription do
  context "to_h" do
    before(:each) do
      @item_dbl = instance_double(Spectrum::Entities::MirlynItem, description: nil, temp_location?: false, temp_location: '')
    end
    subject do 
      #only called with self.for
      described_class.for(item: @item_dbl).to_h
    end
    it "returns default of ''" do
      expect(subject).to eq({text: ''})
    end
    it "returns only description" do
      allow(@item_dbl).to receive(:description).and_return('description')
      expect(subject).to eq({text: 'description'})
    end
    it "returns only temp location" do
      allow(@item_dbl).to receive(:temp_location?).and_return(true)
      allow(@item_dbl).to receive(:temp_location).and_return('MyTempLocation')
      expect(subject).to eq({text: 'Temporary location: Shelved at MyTempLocation'})
    end
    it "returns description and temp location" do
      allow(@item_dbl).to receive(:temp_location?).and_return(true)
      allow(@item_dbl).to receive(:temp_location).and_return('MyTempLocation')
      allow(@item_dbl).to receive(:description).and_return('description')
      expect(subject).to eq({html: '<div>description</div><div>Temporary location: Shelved at MyTempLocation</div>'})
    end
  end

end

