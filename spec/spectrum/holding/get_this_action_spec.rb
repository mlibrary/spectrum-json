# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/holding/action'
require 'spectrum/holding/get_this_action'

describe Spectrum::Holding::GetThisAction do
  context "::match?" do
    let(:data) { YAML.load_file(File.expand_path('../get_this_action_data-01.yml', __FILE__)) }
    it "returns true on example 0" do
      args = data[0]['args']
      expect(described_class.match?(bib_record: args[2], item: args[3], info: args[4])).to eq(true)
    end
  end

  context "#finalize" do
    context "with a basic example" do

      let(:id) { 'ID' }
      let(:datastore) { 'ID' }
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
          datastore: 'ID',
        }
      }}

      subject { described_class.new(doc_id: id, bib_record: bib, holding: item, item_info: info) }

      it 'returns an N/A cell.' do
        expect(subject.finalize).to eq(result)
      end
    end
  end
end
