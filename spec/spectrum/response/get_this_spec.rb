require_relative '../../spec_helper'
require_relative '../../doubles/response_get_this_doubles' #empty dependencies
require './lib/spectrum/response/get_this'

require 'yaml'



describe Spectrum::Response::GetThis do
  describe 'renderable' do
    before(:each) do
      @holdings_source_dbl = double("HoldingsSource", holdings: 'http://localhost')
      @request_dbl = double('Spectrum::Request::GetThis', id: 123456789, barcode: 55555, logged_in?: true, username: 'username')
    end
    it 'returns {} if source.holdings is empty' do
      request_dbl = double('Spectrum::Request::GetThis')
      empty_holdings_source = double("HoldingsSource", holdings: nil)

      get_this = described_class.new(source: empty_holdings_source, request: request_dbl) 
      expect(get_this.renderable).to eq({})
    end
    it 'returns needs_authentication if not logged in' do
      request_dbl= double('Spectrum::Request::GetThis', logged_in?: false)
      get_this = described_class.new(source: @holdings_source_dbl, request: request_dbl) 
      expect(get_this.renderable).to eq( { status: 'Not logged in', options: [] })
    end

    it 'returns patron_expired if patron is expired' do
      expired_aleph_borrower_dbl = double('Aleph::Borrower', bor_info: [], expired?: true)
      get_this = described_class.new(source: @holdings_source_dbl, request: @request_dbl, aleph_borrower: expired_aleph_borrower_dbl ) 
      expect(get_this.renderable).to eq({ status: 'Patron expired', options: [] })
    end

    it 'returns patron_not_found if aleph_error raised'


  end
end
