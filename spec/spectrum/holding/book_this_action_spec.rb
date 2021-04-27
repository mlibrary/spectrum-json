# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../stub_bib_record'


describe Spectrum::Holding::BookThisAction do
  let(:id) { 'ID' }
  let(:bib_record) { nil }
  let(:holding) { nil }
  let(:item_info) {nil}
  let(:item) { instance_double(Spectrum::Entities::MirlynItem, full_item_key: '12345678901234567890') }

  let(:result) {{
    text: 'Book This',
    href: 'http://mirlyn-aleph.lib.umich.edu/F/?adm_doc_number=123456789&adm_item_sequence=012345&adm_library=MIU50&exact_item=N&func=booking-req-form-itm'
  }}

  subject { described_class.new(bib_record: bib_record, item: item) }

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq(result)
    end
  end
end
