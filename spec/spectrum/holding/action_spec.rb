# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/holding/action'
require 'spectrum/holding/get_this_action'
require 'spectrum/holding/request_this_action'
require 'spectrum/holding/book_this_action'

describe Spectrum::Holding::Action do
  subject { described_class.for(doc_id: nil, bib_record: nil, holding: {}, item_info: {}) }

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
  it "returns GetThisAction if given getThis arguments" do
    action = described_class.for(doc_id: nil, bib_record: nil, holding: nil, item_info: {'can_request' => true }) 
    expect(action.class.to_s).to eq('Spectrum::Holding::GetThisAction')
  end
  it "returns BookThisAction if given BookThis arguments" do
    action = described_class.for(doc_id: nil, bib_record: nil, holding: nil, item_info: {'can_book' => true}) 
    expect(action.class.to_s).to eq('Spectrum::Holding::BookThisAction')
  end
  it "returns RequestThisAction if given RequestThis arguments" do
    action = described_class.for(doc_id: nil, bib_record: nil,holding: nil, item_info: {'can_reserve' => true}) 
    expect(action.class.to_s).to eq('Spectrum::Holding::RequestThisAction')
  end
end
