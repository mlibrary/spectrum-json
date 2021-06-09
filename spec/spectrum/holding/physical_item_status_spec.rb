require_relative '../../spec_helper'
describe Spectrum::Holding::PhysicalItemStatus do
  before(:each) do
    @alma_item = instance_double(Spectrum::Entities::AlmaItem) 
  end
  subject do
    described_class.for(@alma_item) 
  end
  context "In place" do
    before(:each) do
      allow(@alma_item).to receive("in_place?").and_return(true)
    end
    context "Policy: Loan 1" do
      before(:each) do
        allow(@alma_item).to receive(:item_policy).and_return('01')
      end
      it "returns success status for non-requested item" do
#        allow(@alma_item).to receive(:requested?).and_return(false)
        expect(subject.to_h).to eq({text: 'On shelf', intent: 'success', icon: 'check_circle'})
        expect(subject.class.to_s).to include('Success')
      end
      #it "returns error for requested item" do
        #allow(@alma_item).to receive(:requested?).and_return(true)
        #expect(subject.to_h).to eq({text: 'Requested', intent: 'error', icon: 'error'})
        #expect(subject.class.to_s).to include('Error')
      #end
    end
    context "Policy: Loan 08" do
      before(:each) do
        allow(@alma_item).to receive(:item_policy).and_return('08')
      end
      it "handles building_use_only" do
        allow(@alma_item).to receive(:library).and_return('MUSIC')
        expect(subject.class.to_s).to include('Success')
        expect(subject.text).to eq('Building use only')
      end
      ['SPEC', 'BENT', 'CLEM'].each do |library|
        it "is Reading Room Use Only for #{library} " do
          allow(@alma_item).to receive(:library).and_return(library)
          expect(subject.class.to_s).to include('Success')
          expect(subject.text).to eq('Reading Room Use Only')
        end
      end
    end
    [
      {value: '06', desc: '4 Hour Loan'},
      {value: '07', desc: '2 Hour Loan'},
      {value: '11', desc: '6 Hour Loan'},
      {value: '12', desc: '12 Hour Loan'}
    ].each do |policy|
      context "Policy: #{policy[:desc]}" do
        it "returns On Shelf and length of time" do
          allow(@alma_item).to receive(:item_policy).and_return(policy[:value])
          expect(subject.class.to_s).to include('Success')
          expect(subject.text).to eq("On shelf (#{policy[:desc]})")
        end
      end

    end
  end
end

