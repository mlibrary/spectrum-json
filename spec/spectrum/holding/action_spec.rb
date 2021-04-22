# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/holding/action'
require 'spectrum/item'
require 'spectrum/holding/get_this_action'
require 'spectrum/holding/request_this_action'
require 'spectrum/holding/book_this_action'

describe Spectrum::Holding::Action do

  subject do 
    plain_item = instance_double(Spectrum::Item, "can_request?"=> false, "can_book?"=> false, "can_reserve?" => false, item_process_status: nil, item_status: nil, sub_library: 'FVL' ) 

    described_class.for(item: plain_item, bib_record: nil)
  end

  context "::label" do
    it 'returns N/A' do
      expect(subject.label).to eq('N/A')
    end
  end
  

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq({text: 'N/A'})
    end
  end
end

describe Spectrum::Holding::Action, ".for" do
  before(:each) do
    @item = instance_double(Spectrum::Item, "can_request?" => false, "can_book?" => false, "can_reserve?" => false)
  end
  it "returns GetThisAction if given getThis arguments" do
    allow(@item).to receive("can_request?").and_return(true)
    action = described_class.for(item: @item, bib_record: nil) 
    expect(action.class.to_s).to eq('Spectrum::Holding::GetThisAction')
  end
  it "returns BookThisAction if given BookThis arguments" do
    allow(@item).to receive("can_book?").and_return(true)
    action = described_class.for(item: @item, bib_record: nil ) 
    expect(action.class.to_s).to eq('Spectrum::Holding::BookThisAction')
  end
  it "returns RequestThisAction if given RequestThis arguments" do
    allow(@item).to receive("can_reserve?").and_return(true)
    action = described_class.for(item: @item, bib_record: nil) 
    expect(action.class.to_s).to eq('Spectrum::Holding::RequestThisAction')
  end
end
