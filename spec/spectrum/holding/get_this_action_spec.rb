# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/holding/action'
require 'spectrum/holding/get_this_action'
require 'spectrum/item'

describe Spectrum::Holding::GetThisAction do
  context "::match?" do

    let(:doc_id) {'000045521'}
    let(:holding) { JSON.parse(File.read('./spec/fixtures/get_this_action_getholdings.json'))[doc_id] }
    let(:item_info) {holding[1]["item_info"].first}

    let(:item){Spectrum::Item.new(doc_id: doc_id, holdings: holding, item: item_info)}

    it "returns true on example 0" do
      expect(described_class.match?(item)).to eq(true)
    end
  end

  context "#finalize" do
    context "with a basic example" do

      let(:id) { 'ID' }
      let(:bib) { nil }
      let(:holding) {{
        'item_status' => ''
      }}
      let(:item) { instance_double(Spectrum::Item, barcode: 'BARCODE', doc_id: 'ID') }
      let(:info) {{ 'can_request' => true, 'barcode' => 'BARCODE' }}
      let(:result) {{
        text: 'Get This',
        to: {
          barcode: 'BARCODE',
          action: 'get-this',
          record: 'ID',
          datastore: 'ID',
        }
      }}

      subject { described_class.new(doc_id: id, bib_record: bib, holding: holding, item_info: info, item: item) }

      it 'returns an N/A cell.' do
        expect(subject.finalize).to eq(result)
      end
    end
  end
end
