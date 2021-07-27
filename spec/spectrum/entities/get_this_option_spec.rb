require_relative '../../spec_helper'
describe Spectrum::Entities::GetThisOption do
  before(:each) do
     @account = instance_double(Spectrum::Entities::AlmaUser)
     @item = double('Spectrum::Decorators::PhysicalItemDecorator')
     Spectrum::Entities::GetThisOptions.configure('spec/fixtures/new_get_this_policy.yml')
  end
  context "Alma Hold" do
    subject do 
      hold = Spectrum::Entities::GetThisOptions.all[0]
      described_class.for(option: hold, 
        account: @account, item: @item)
    end
    it "returns an alma hold" do
      expect(subject.class.to_s).to include('AlmaHold')
    end
    it "has a proper looking form" do
      allow(@item).to receive(:mms_id).and_return('MMS_ID')
      allow(@item).to receive(:holding_id).and_return('HOLDING_ID')
      allow(@item).to receive(:item_id).and_return('ITEM_ID')
      expect(subject.form('DATE')).to eq(JSON.parse(File.read('./spec/fixtures/get_this/alma_hold.json')))
    end
  end
end

