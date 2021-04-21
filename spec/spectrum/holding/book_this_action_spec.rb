# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../stub_bib_record'

require 'spectrum/holding/action'
require 'spectrum/holding/book_this_action'
require 'active_support'
require 'active_support/core_ext/hash'
require 'exlibris-aleph'

describe Spectrum::Holding::BookThisAction do
  let(:id) { 'ID' }
  let(:datastore) { 'DATASTORE' }
  let(:bib) { StubBibRecord.new }
  let(:item) { nil }
  let(:info) {{
    'can_book' => true,
    'full_item_key' => '12345678901234567890', 
  }}
  let(:result) {{
    text: 'Book This',
    href: 'http://mirlyn-aleph.lib.umich.edu/F/?adm_doc_number=123456789&adm_item_sequence=012345&adm_library=MIU50&exact_item=N&func=booking-req-form-itm'
  }}

  subject { described_class.new(doc_id: id, bib_record: bib, holding: item, item_info: info) }

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq(result)
    end
  end
end
