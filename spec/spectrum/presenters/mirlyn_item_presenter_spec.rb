require_relative '../../spec_helper'

describe Spectrum::Presenters::MirlynItem, "to_a" do
    before(:each) do

    @to_a_init = {
      action: instance_double(Spectrum::Holding::Action, finalize: nil),
      description: instance_double(Spectrum::Holding::PhysicalItemDescription, to_h: {text: 'N/A'}),
      intent: 'intent', icon: 'icon'
    }
    
    @item = instance_double(Spectrum::Entities::MirlynItem, status: 'On Shelf', callnumber: 'call_number', can_request?: false, inventory_number: nil)
  
  end
  subject do
    described_class.new(bib_record: nil, item: @item).to_a(**@to_a_init)
  end
  it "returns an array" do
    expect(subject.class.name).to eq('Array')
  end
  it "returns appropriate status" do
    expect(subject[2]).to eq( {text: 'On Shelf', intent: 'intent', icon: 'icon'}) 
  end
  it "returns call number" do
    expect(subject[3]).to eq( {text: @item.callnumber}) 
  end
  it "handles Video call number" do
    allow(@item).to receive(:callnumber).and_return('VIDEO call_number')
    allow(@item).to receive(:inventory_number).and_return('12345')
    expect(subject[3]).to eq( {text: 'VIDEO call_number - 12345'}
    ) 
  end
  it "handles nil call_number" do
    allow(@item).to receive(:callnumber).and_return(nil)
    expect(subject[3]).to eq( {text: 'N/A'}) 
  end
end
