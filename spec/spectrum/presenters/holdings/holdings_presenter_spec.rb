require_relative '../../../spec_helper'
require 'spectrum/presenters/holdings/holding_presenter'

describe Spectrum::Presenters::HathiTrustHoldingPresenter, "to_h" do
  before(:each) do
    @id = "000311635"
    @raw = JSON.parse(File.read('spec/fixtures/hurdy_gurdy_getHoldings.json'))
    @holding = @raw[@id].first 
    @item_info =  @holding["item_info"]
    @holding_input = double('Spectrum::Response::Holdings::HoldingInput', holding: @holding, raw: @raw, id:@id, bib_record: nil)
  end
  subject do
    described_class.new(@holding_input).to_h
  end
  it "returns item href with suffix when  'log in required' is in the status" do
    expect(subject[:rows][0][0][:href]).to eq("http://hdl.handle.net/2027/#{@item_info.first['id']}?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth")
  end
  it "returns item href without suffix when  'log in required' isn't in the status" do
    @item_info.first["status"] = '' 
    expect(subject[:rows][0][0][:href]).to eq("http://hdl.handle.net/2027/#{@item_info.first['id']}")
  end
end
