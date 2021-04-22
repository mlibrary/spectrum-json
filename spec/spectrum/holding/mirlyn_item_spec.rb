require_relative '../../spec_helper'
require 'spectrum/json'

describe Spectrum::Holding::MirlynItem, "to_a" do
    before(:each) do

    @to_a_init = {
      action: instance_double(Spectrum::Holding::Action, finalize: nil),
      description: instance_double(Spectrum::Holding::MirlynItemDescription, to_h: {text: 'N/A'}),
      intent: 'intent', icon: 'icon'
    }
    
    @item_dbl = instance_double(Spectrum::Item, status: 'On Shelf', callnumber: 'call_number', can_request?: false, inventory_number: nil)
  
    @mirlyn_item_init = {
      holding_input: double('Spectrum::Response::Holdings::HoldingInput', holding: nil, raw: nil, id:nil, bib_record: nil),
      item_info: {'inventory_number' => nil},
      item_factory: lambda{|x, y, z| @item_dbl}
    }

  end
  subject do
    described_class.new(**@mirlyn_item_init).to_a(**@to_a_init)
  end
  it "returns an array" do
    expect(subject.class.name).to eq('Array')
  end
  it "returns appropriate status" do
    expect(subject[2]).to eq( {text: 'On Shelf', intent: 'intent', icon: 'icon'}) 
  end
  it "returns call number" do
    expect(subject[3]).to eq( {text: @item_dbl.callnumber}) 
  end
  it "handles Video call number" do
    allow(@item_dbl).to receive(:callnumber).and_return('VIDEO call_number')
    allow(@item_dbl).to receive(:inventory_number).and_return('12345')
    expect(subject[3]).to eq( {text: 'VIDEO call_number - 12345'}
    ) 
  end
  it "handles nil call_number" do
    allow(@item_dbl).to receive(:callnumber).and_return(nil)
    expect(subject[3]).to eq( {text: 'N/A'}) 
  end
end
