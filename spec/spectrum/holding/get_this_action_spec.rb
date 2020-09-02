# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/holding/action'
require 'spectrum/holding/get_this_action'

describe Spectrum::Holding::GetThisAction do
  let(:id) { 'ID' }
  let(:datastore) { 'DATASTORE' }
  let(:bib) { nil }
  let(:item) {{
    'item_status' => ''
  }}
  let(:info) {{ 'can_request' => true, 'barcode' => 'BARCODE' }}
  let(:result) {{
    text: 'Get This',
    to: {
      barcode: 'BARCODE',
      action: 'get-this',
      record: 'ID',
      datastore: 'DATASTORE',
    }
  }}

  subject { described_class.new(id, datastore, bib, item, info) }

  context "#finalize" do
    it 'returns an N/A cell.' do
      expect(subject.finalize).to eq(result)
    end
  end
end
