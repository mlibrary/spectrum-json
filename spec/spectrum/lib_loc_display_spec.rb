require_relative '../spec_helper'
require 'spectrum/lib_loc_display'

describe Spectrum::LibLocDisplay do
    before(:each) do
      described_class.configure('spec/fixtures/lib_loc_display.json')
    end

  context '::link' do
    it 'returns a link' do
      expect(described_class.link('HATCH', 'GRAD')).to eq("http://www.lib.umich.edu/location/hatcher-graduate-library/unit/25")
    end
  end
  context '::text' do
    it 'returns a link' do
      expect(described_class.text('HATCH', 'GRAD')).to eq("Hatcher Graduate")
    end
  end
end
