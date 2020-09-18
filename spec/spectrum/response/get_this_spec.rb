require_relative '../../spec_helper'
require 'spectrum/response/get_this'

#collaborators
require 'spectrum/policy/get_this'
require 'spectrum/holding'
require 'spectrum/item'
require 'spectrum/bib_record'

require 'yaml'

class BibRecordDouble
  attr_reader :solr_response
  def initialize(solr_response)
    @solr_response = solr_response
  end
end

class GetThisPolicyDouble
  attr_reader :account, :bib, :item
  def initialize(account, bib, item)
    @account = account
    @bib = bib
    @item = item
  end
  
 
  def resolve
    self
  end
end

class AlephErrorDouble
end

describe Spectrum::Response::GetThis do
  describe 'renderable' do
    before(:each) do
      @item_dbl = class_double(Spectrum::Item, for: 'MyItem')
      @init = { 
                source: double("HoldingsSource", holdings: 'http://localhost', url: 'mirlyn_solr_url'),
                request: double('Spectrum::Request::GetThis', id: '123456789', barcode: '55555', logged_in?: true, username: 'username'),
                get_this_policy: GetThisPolicyDouble,
                aleph_borrower: double('Aleph::Borrower', bor_info: [], expired?: false), 
                aleph_error: AlephErrorDouble,
                bib_record: 'Spectrum::BibRecord',
                item_picker: lambda{|request| @item_dbl.for(request: request)},
      }
      @holdings_source_dbl = double("HoldingsSource", holdings: 'http://localhost', url: 'mirlyn_solr_url')
      @request_dbl = double('Spectrum::Request::GetThis', id: '123456789', barcode: '55555', logged_in?: true, username: 'username')
    end


    it 'returns {} if source.holdings is empty' do

      @init[:source] = double("HoldingsSource", holdings: nil)

      get_this = described_class.new(**@init )
      expect(get_this.renderable).to eq({})
    end
    it 'returns needs_authentication if not logged in' do
      @init[:request] = double('Spectrum::Request::GetThis', logged_in?: false)
      get_this = described_class.new(**@init) 
      expect(get_this.renderable).to eq( { status: 'Not logged in', options: [] })
    end

    it 'returns patron_expired if patron is expired' do
      @init[:aleph_borrower]  = double('Aleph::Borrower', bor_info: [], expired?: true)
      get_this = described_class.new(**@init) 
      expect(get_this.renderable).to eq({ status: 'Patron expired', options: [] })
    end

    it 'returns patron_not_found if aleph_error raised' do
      allow(@init[:aleph_borrower]).to receive(:bor_info) {raise Aleph::Error, 'Borrower not set'} 

      @init.delete(:aleph_error)
      get_this = described_class.new(**@init) 
      expect(get_this.renderable).to eq({ status: 'Patron not found', options: [] })
    end
    
    it 'calls get_this_policy with bib_record' do

      get_this = described_class.new(**@init) 
            
      expect(get_this.renderable[:options].bib).to eq('Spectrum::BibRecord')
    end
    
    it 'calls get_this_policy with Spectrum::Item' do

      expect(@item_dbl).to receive(:for).with(hash_including(request: @init[:request]))
      get_this = described_class.new(**@init) 
      
      expect(get_this.renderable[:options].item).to eq(@item_dbl.for(request: nil))
    end
  end
end
