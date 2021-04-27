require_relative '../../spec_helper'
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


describe Spectrum::Response::GetThis do
  describe 'renderable' do
    before(:each) do
      @mirlynItem_dbl = class_double(Spectrum::Decorators::MirlynItemDecorator)
      @init = { 
                source: double("HoldingsSource", holdings: 'http://localhost', url: 'mirlyn_solr_url'),
                request: double('Spectrum::Request::GetThis', id: '123456789', barcode: '55555', logged_in?: true, username: 'username'),

                get_this_policy_factory: lambda{|patron, bib_record, holdings_record| GetThisPolicyDouble.new( patron, bib_record, holdings_record)},
                aleph_borrower: double('Aleph::Borrower', bor_info: [], expired?: false), 
                bib_record: 'Spectrum::BibRecord',
                item_picker: lambda{|request, source| @mirlynItem_dbl}
      }
    end

    subject do
      described_class.new(**@init)
    end

    it 'returns {} if source.holdings is empty' do
      @init[:source] = double("HoldingsSource", holdings: nil)
      expect(subject.renderable).to eq({})
    end
    it 'returns needs_authentication if not logged in' do
      @init[:request] = double('Spectrum::Request::GetThis', logged_in?: false)
      expect(subject.renderable).to eq( { status: 'Not logged in', options: [] })
    end

    it 'returns patron_expired if patron is expired' do
      @init[:aleph_borrower]  = double('Aleph::Borrower', bor_info: [], expired?: true)
      expect(subject.renderable).to eq({ status: 'Patron expired', options: [] })
    end

    it 'returns patron_not_found if aleph_error raised' do
      allow(@init[:aleph_borrower]).to receive(:bor_info) {raise Aleph::Error, 'Borrower not set'} 

      expect(subject.renderable).to eq({ status: 'Patron not found', options: [] })
    end
    
    it 'calls get_this_policy with bib_record' do
      expect(subject.renderable[:options].bib).to eq('Spectrum::BibRecord')
    end
    
    it 'calls get_this_policy with Spectrum::Decorators::MirlynItemDecorator' do
      expect(subject.renderable[:options].item).to eq(@mirlynItem_dbl)
    end
  end
end
