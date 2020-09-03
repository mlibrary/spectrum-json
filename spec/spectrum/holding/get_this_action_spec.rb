# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/holding/action'
require 'spectrum/holding/get_this_action'

describe Spectrum::Holding::GetThisAction do
  context "::match?" do
    let(:data) { YAML.load_file(File.expand_path('../get_this_action_data-01.yml', __FILE__)) }
    it "returns true on example 0" do
      expect(described_class.match?(*data[0]['args'])).to eq(data[0]['match'])
    end
  end

  context "#finalize" do
    context "with a basic example" do

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

      it 'returns an N/A cell.' do
        expect(subject.finalize).to eq(result)
      end
    end
  end
end
