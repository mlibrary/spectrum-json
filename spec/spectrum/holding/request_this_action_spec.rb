# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../stub_bib_record'

describe Spectrum::Holding::RequestThisAction do
  let(:id) { 'ID' }
  let(:bib) { StubBibRecord.new }
  let(:holding) {{ 'can_reserve' => true }}
  let(:info) {{ 'can_reserve' => true }}
  let(:item) { instance_double(Spectrum::Entities::MirlynItem, full_item_key: '12345678901234567890', 
      barcode: nil, collection: nil, inventory_number: nil, sub_library: nil, callnumber: nil,
      description: nil, doc_id: id)}
  let(:result) {{
    text: 'Request This',
    href: 'https://iris.lib.umich.edu/aeon/?Action=10&Form=30&ItemAuthor=author&barcode=&callnumber=&date=pub_date&description=&extent=physical_description&fixedshelf=&genre=genre&isbn=isbn&issn=issn&itemDate=date&itemPlace=place&itemPublisher=pub&location=&publisher=publisher&restriction=restriction&rft.au=author&rft.edition=edition&sgenre=sgenre&sublocation=&sysnum=ID&title=title'
  }}

  subject { described_class.new(item: item,bib_record: bib) }

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq(result)
    end
  end
end
