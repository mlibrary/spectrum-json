require_relative '../../spec_helper'
require 'spectrum/response/holdings'
require 'spectrum/utility/http_client'
require 'spectrum/utility/bib_fetcher'
require 'spectrum/floor_location'
require 'aleph'

describe Spectrum::Response::Holdings do
  
  describe 'renderable' do
    before(:each) do
      @bib_record = double('Spectrum::BibRecord', physical_only?: false)
      @init= {
        :source => double("HoldingsSource", holdings: 'blah', url: nil),
        :request => double('Spectrum::Request::Holdings', id: '000311635', focus: nil),
        :client => double('Spectrum::Utility::HttpClient', get: JSON.parse(File.read('./spec/fixtures/hurdyGurdyHoldings.json'))),
        :bib_fetcher => double('Spectrum::Utility::BibFetcher', fetch: @bib_record)
      }

    end
    it "returns something" do
      
       allow(Aleph).to receive(:intent)
       allow(Aleph).to receive(:icon)
       allow(Spectrum::FloorLocation).to receive(:resolve)
       described_class.new(**@init).renderable   
    end
  end
end