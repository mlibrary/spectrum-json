# frozen_string_literal: true

require_relative '../spec_helper'

describe Spectrum::FloorLocation do
  context '::resolve' do
    before do
      described_class.configure(File.expand_path('../floor_locations.json', __FILE__))
    end

    it 'resolves "GRAD / ac" to 1 North' do
      expect(described_class.resolve('HATCH', 'GRAD', 'ac')).to eql('1 North')
    end
  end
end
