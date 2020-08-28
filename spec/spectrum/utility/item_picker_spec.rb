require_relative '../../spec_helper'
require 'spectrum/utility/item_picker'
require 'spectrum/item'
require 'spectrum/available_online_holding'

describe Spectrum::Utility::ItemPicker, "item(request:)" do
  before(:each) do
    @client_dbl = double('Spectrum::Utility::AlmaClient')
    @request_dbl = double('Spectrum::Request::GetThis', id: nil, username: nil, barcode: '0919242913')
  end

  subject { described_class.new() }
  it "returns loaded item for valid barcode" do
    response_dbl = double('HTTParty::Response', parsed_response: JSON.parse(File.read('./spec/fixtures/plain_words_on_singing_item.json')), code: 200 )
    allow(@client_dbl).to receive(:get).and_return(response_dbl)


    item = subject.item(request: @request_dbl, client: @client_dbl)
    expect(item.barcode).to eq('0919242913')
    expect(item.class.name).to eq('Spectrum::Item')
  end

  it "returns NullItem for error received" do
    response_dbl = double('HTTParty::Response', parsed_response: JSON.parse(File.read('./spec/fixtures/item_error.json')), code: 400 )
    allow(@client_dbl).to receive(:get).and_return(response_dbl)
    item = subject.item(request: @request_dbl, client: @client_dbl)
    expect(item.barcode).to eq('0919242913')
    expect(item.class.name).to eq('Spectrum::NullItem')
  end

  it "returns AvailabileOnlineHolding when barcode is 'available-online'" do
    allow(@request_dbl).to receive(:barcode).and_return('available-online')
    allow(@request_dbl).to receive(:id).and_return('mms_id')
    item = subject.item(request: @request_dbl, client: @client_dbl)
    expect(item.class.name).to eq('Spectrum::AvailableOnlineHolding')
  end
end
