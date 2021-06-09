# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../stub_bib_record'

describe Spectrum::Holding::RequestThisAction, ".match" do
  before(:each) do
    @item = instance_double(Spectrum::Entities::AlmaItem, library: 'HATCH')
  end
  subject do
    described_class.match?(@item)
  end
  it "generally does not match" do
    expect(subject).to eq(false)
  end
  it "matches SPEC" do
    allow(@item).to receive(:library).and_return('SPEC')
    expect(subject).to eq(true)
  end
  it "matches BENT" do
    allow(@item).to receive(:library).and_return('BENT')
    expect(subject).to eq(true)
  end
  it "matches CLEM" do
    allow(@item).to receive(:library).and_return('CLEM')
    expect(subject).to eq(true)
  end
end
describe Spectrum::Holding::RequestThisAction do
  
  let(:bib_record){ 

    methods = [
      :mms_id,
      :genre, 
      :sgenre, 
      :restriction, 
      :edition, 
      :physical_description, 
      :date, 
      :pub, 
      :place, 
      :publisher, 
      :pub_date, 
      :author, 
      :title, 
      :isbn, 
      :issn, 
    ].map{|x| [x,x]}.to_h
    instance_double(Spectrum::BibRecord, **methods)

  }

  let(:solr_item){ 
    methods = [:library, :callnumber, :description, :location, :barcode,
               :inventory_number].map{|x| [x,x]}.to_h
    double("BibRecord::AlmaHolding::Item", **methods) 
  }

  let(:item){Spectrum::Entities::AlmaItem.new(holding: nil, alma_item: {}, bib_record: bib_record, solr_item: solr_item) }

  let(:result) {{
    text: 'Request This',
    href: 'https://iris.lib.umich.edu/aeon/?Action=10&Form=30&ItemAuthor=author&barcode=barcode&callnumber=callnumber&date=pub_date&description=description&extent=physical_description&fixedshelf=inventory_number&genre=genre&isbn=isbn&issn=issn&itemDate=date&itemPlace=place&itemPublisher=pub&location=library&publisher=publisher&restriction=restriction&rft.au=author&rft.edition=edition&sgenre=sgenre&sublocation=location&sysnum=mms_id&title=title'
  }}

  subject { described_class.new(item) }

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq(result)
    end
  end
end
