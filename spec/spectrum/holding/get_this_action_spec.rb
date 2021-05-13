# frozen_string_literal: true

require_relative '../../spec_helper'

describe Spectrum::Holding::GetThisAction do
  context "::match?" do

    #let(:holding) { JSON.parse(File.read('./spec/fixtures/get_this_action_getholdings.json')) }
    let(:holding) { JSON.parse(File.read('./spec/fixtures/alma_one_holding.json')) }
    let(:solr) {Spectrum::BibRecord.new(JSON.parse(File.read('./spec/fixtures/solr_bib_alma.json')))}

    let(:item) do
      #Spectrum::Entities::MirlynItem
      #Spectrum::Entities::Holdings.new(holding)[1].items.first
      Spectrum::Entities::AlmaHoldings.new(alma: holding, solr: solr)[0].items.first
      
    end

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
      let(:item) { instance_double(Spectrum::Entities::AlmaItem, barcode: 'BARCODE', doc_id: 'ID') }
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

      subject { described_class.new(bib_record: bib, item: item) }

      it 'returns an N/A cell.' do
        expect(subject.finalize).to eq(result)
      end
    end
  end
end
