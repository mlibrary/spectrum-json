# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/holding/action'

describe Spectrum::Holding::Action do
  subject { described_class.new(nil, nil, nil, {}, {}) }

  context "::label" do
    it 'returns N/A' do
      expect(described_class.label).to eq('N/A')
    end
  end

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq({text: 'N/A'})
    end
  end
end
