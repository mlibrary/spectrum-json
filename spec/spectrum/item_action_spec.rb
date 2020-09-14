require_relative '../spec_helper'
require 'spectrum/item_action'
require 'spectrum/item'
require 'spectrum/bib_record'
require 'spectrum/utility/bib_fetcher'
require 'rails' #for 'to_query'

describe Spectrum::ItemAction do
  before(:each)do
    @item_dbl = instance_double(Spectrum::Item)
  end
  context "to_h" do
    it "returns appropriate hash" do
      expect(described_class.new(item: @item_dbl).to_h).to eq({text: 'N/A'})
    end
  end
  context "self.for" do
    before(:each) do
      allow(@item_dbl).to receive(:record).and_return('id')
      @bib_dbl = double('Spectrum::BibRecord')
      @params = {item: @item_dbl, bib: @bib_dbl}
    end
    it "returns RequestItemAction when can_request" do
      allow(@item_dbl).to receive(:can_request?).and_return(true)
      expect(described_class.for(**@params).class.name).to eq('Spectrum::RequestItemAction')
    end
    it "returns ReserveItemAction when  can_reserve" do
      allow(@item_dbl).to receive(:can_request?).and_return(false)
      allow(@item_dbl).to receive(:can_reserve?).and_return(true)
      expect(described_class.for(**@params).class.name).to eq('Spectrum::ReserveItemAction')
    end
    it "returns BookItemAction when can_book" do
      allow(@item_dbl).to receive(:can_request?).and_return(false)
      allow(@item_dbl).to receive(:can_reserve?).and_return(false)
      allow(@item_dbl).to receive(:can_book?).and_return(true)
      expect(described_class.for(**@params).class.name).to eq('Spectrum::BookItemAction')
    end
    it "returns ItemAction when can't do anything" do
      allow(@item_dbl).to receive(:can_request?).and_return(false)
      allow(@item_dbl).to receive(:can_reserve?).and_return(false)
      allow(@item_dbl).to receive(:can_book?).and_return(false)
      expect(described_class.for(**@params).class.name).to eq('Spectrum::ItemAction')
    end

  end
end

describe Spectrum::RequestItemAction, 'to_h' do
  it "returns appropriate hash" do
    item_dbl = instance_double(Spectrum::Item, barcode: '12345', record: '555')
    expect(described_class.new(item: item_dbl).to_h).to eq( 
      {
         text: 'Get this', 
         to: {
          barcode: '12345', 
          action: 'get-this', 
          record: '555', 
          datastore: '555'
        }
      }) 
  end 
end
describe Spectrum::BookItemAction, 'to_h' do
  it "returns appropriate hash" do
    item_dbl = double('Spectrum::Item')
    expect(described_class.new(item: item_dbl).to_h[:text]).to eq('Book this') 
  end 
end
describe Spectrum::ReserveItemAction do
  before(:each) do
    @item_dbl = instance_double(Spectrum::Item, record: 'record', barcode: 'barcode', collection: 'collection', inventory_number: 'inventory_number', call_number: 'call_number', description: 'description', library: 'library') 
    @bib_dbl = instance_double(Spectrum::BibRecord, genre: 'genre', sgenre: 'sgenre', issn: 'issn',
                 isbn: 'isbn', pub_date: 'pub_date', title: 'title', author: 'author', pub: 'pub', 
                 publisher: 'publisher', place: 'place',  edition: 'edition', 
                 physical_description: 'physical_description', restriction: 'restriction',
               ) 
  end
  context "to_h" do
    subject do
      described_class.new(item: @item_dbl, bib: @bib_dbl).to_h
    end
    it "returns appropriate text value" do
      expect(subject[:text]).to eq('Request this')
    end 
    it "returns bentley href" do
      allow(@item_dbl).to receive(:library).and_return('BENT')
      expect(subject[:href]).to start_with('https://aeon.bentley.umich.edu/login?')
    end
    it "returns clements href" do
      allow(@item_dbl).to receive(:library).and_return('CLEM')
      expect(subject[:href]).to start_with('https://chara.clements.umich.edu/aeon/?')
    end
    it "returns default href" do
      expect(subject[:href]).to start_with('https://iris.lib.umich.edu/aeon/?')
    end
  end
  context "query_fields" do
    subject do
      described_class.new(item: @item_dbl, bib: @bib_dbl).query_fields
    end
    it "returns Action of '10'" do
      expect(subject[:Action]).to eq('10')
    end
    it "returns Form of '30'" do
      expect(subject[:Form]).to eq('30')
    end
    it "returns genre" do
      expect(subject[:genre]).to eq('genre')
    end
    it "returns sgenre" do
      expect(subject[:sgenre]).to eq('sgenre')
    end
    it "returns sysnum" do
      expect(subject[:sysnum]).to eq('record')
    end
    it "returns issn" do
      expect(subject[:issn]).to eq('issn')
    end
    it "returns isbn" do
      expect(subject[:isbn]).to eq('isbn')
    end
    it "returns title" do
      expect(subject[:title]).to eq('title')
    end
    it "returns ItemAuthor" do
      expect(subject[:ItemAuthor]).to eq('author')
    end
    it "returns 'rft.au'" do
      expect(subject[:'rft.au']).to eq('author')
    end
    it "returns date" do
      expect(subject[:date]).to eq('pub_date')
    end
    it "returns publisher" do
      expect(subject[:publisher]).to eq('publisher')
    end
    it "returns itemPlace" do
      expect(subject[:itemPlace]).to eq('place')
    end
    it "returns itemPublisher" do
      expect(subject[:itemPublisher]).to eq('pub')
    end
    it "returns itemDate" do
      expect(subject[:itemDate]).to eq('pub_date')
    end
    it "returns extent" do
      expect(subject[:extent]).to eq('physical_description')
    end
    it "returns 'rft.edition'" do
      expect(subject[:'rft.edition']).to eq('edition')
    end
    it "returns callnumber" do
      expect(subject[:callnumber]).to eq('call_number')
    end
    it "returns description" do
      expect(subject[:description]).to eq('description')
    end
    it "returns location" do
      expect(subject[:location]).to eq('library')
    end
    it "handles Bentley" do
      allow(@item_dbl).to receive(:library).and_return('BENT')
      expect(subject[:location]).to be_nil
    end
    it "returns sublocation" do
      expect(subject[:sublocation]).to eq('collection')
    end
    it "returns barcode" do
      expect(subject[:barcode]).to eq('barcode')
    end
    it "returns fixedshelf" do
      expect(subject[:fixedshelf]).to eq('inventory_number')
    end
    it "returns restriction" do
      expect(subject[:restriction]).to eq('restriction')
    end
    it "handles too long title" do
      allow(@bib_dbl).to receive(:title).and_return("a" * 300)
      expect(subject[:title]).to eq("a"*250)
    end
    it "handles nil title" do
      allow(@bib_dbl).to receive(:title).and_return(nil)
      expect(subject[:title]).to eq('')
    end
    
  end
end
