# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../stub_bib_record'

require 'spectrum/holding/action'
require 'spectrum/holding/request_this_action'
require 'active_support'
require 'active_support/core_ext/hash'

describe Spectrum::Holding::RequestThisAction do
  let(:id) { 'ID' }
  let(:datastore) { 'DATASTORE' }
  let(:bib) { StubBibRecord.new }
  let(:item) {{ 'can_reserve' => true }}
  let(:info) {{ 'can_reserve' => true }}
  let(:result) {{
    text: 'Request This',
    href: 'https://iris.lib.umich.edu/aeon/?Action=10&Form=30&ItemAuthor=author&barcode=&callnumber=&date=pub_date&description=&extent=physical_description&fixedshelf=&genre=genre&isbn=isbn&issn=issn&itemDate=date&itemPlace=place&itemPublisher=pub&location=&publisher=publisher&restriction=restriction&rft.au=author&rft.edition=edition&sgenre=sgenre&sublocation=&sysnum=ID&title=title'
  }}

  subject { described_class.new(doc_id: id, bib_record: bib, holding: item, item_info: info) }

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq(result)
    end
  end
end
