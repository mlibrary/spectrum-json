require_relative '../../spec_helper'
require 'spectrum/response/get_this'

#collaborators
require 'spectrum/policy/get_this'
require 'spectrum/available_online_holding'
require 'spectrum/holding'
require 'spectrum/bib_record'
require 'spectrum/utility/http_client'
require 'spectrum/utility/solr'

require 'yaml'

class HoldingDouble
  attr_reader :holdings, :id, :barcode
  def initialize(holdings, id, barcode)
    @holdings = holdings
    @id = id
    @barcode = barcode
  end
end
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
      @init = { 
                source: double("HoldingsSource", holdings: 'http://localhost', url: 'mirlyn_solr_url'),
                request: double('Spectrum::Request::GetThis', id: '123456789', barcode: '55555', logged_in?: true, username: 'username'),
                get_this_policy: GetThisPolicyDouble,
                aleph_borrower: double('Aleph::Borrower', bor_info: [], expired?: false), 
                aleph_error: AlephErrorDouble,
                holding: HoldingDouble, bib_record: BibRecordDouble,
                client: double('Spectrum::Utility::HttpClient', get: nil),
                solr: double('Spectrum::Utility::Solr'),
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

    it 'returns patron_not_found if aleph_error raised'
    
    it 'calls get_this_policy with bib_record' do
      @init[:client] = double('Spectrum::Utility::HttpClient', get: [])
      rsolr_client = double( 'RSolr.connect', get: 'mybib' )
      @init[:solr] = double('Spectrum::Utility::Solr', connect: rsolr_client, solr_escape: '')

      get_this = described_class.new(**@init) 
            
      expect(get_this.renderable[:options].bib.solr_response).to eq('mybib')
    end
    
    it 'calls get_this_policy with holdings_record' do
      aleph_borrower_dbl = double('Aleph::Borrower', bor_info: [], expired?: false)

      @init[:client] = double('Spectrum::Utility::HttpClient', get: 'myholdings')
      rsolr_client = double( 'RSolr.connect', get: '' )
      @init[:solr] = double('Spectrum::Utility::Solr', connect: rsolr_client, solr_escape: '')

      get_this = described_class.new(**@ini) 
            
      expect(get_this.renderable[:options].item.holdings).to eq('myholdings')
      expect(get_this.renderable[:options].item.id).to eq('123456789')
      expect(get_this.renderable[:options].item.barcode).to eq('55555')
    end
  end
end
