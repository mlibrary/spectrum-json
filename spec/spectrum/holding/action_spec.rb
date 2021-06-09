# frozen_string_literal: true

require_relative '../../spec_helper'

describe Spectrum::Holding::Action, ".for" do
  before(:each) do
    @item = instance_double(Spectrum::Entities::AlmaItem, item_policy: '01', "can_book?" => false, "can_reserve?" => false, library: 'SHAP', "etas?"=>false, process_type: nil )
  end
  subject do
    described_class.for(@item) 
  end
  it "returns NoAction" do
    allow(@item).to receive("item_policy").and_return('06')
    expect(subject.class.to_s).to eq('Spectrum::Holding::NoAction')
  end
  it "returns RequestThisAction if given RequestThis arguments" #do
    #allow(@item).to receive("library").and_return('SPEC')
    #expect(subject.class.to_s).to eq('Spectrum::Holding::RequestThisAction')
  #end
  it "returns GetThisAction if it doesn't fall into the others" do
    expect(subject.class.to_s).to eq('Spectrum::Holding::GetThisAction')
  end
end
