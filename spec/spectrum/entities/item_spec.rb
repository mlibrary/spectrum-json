# frozen_string_literal: true

require_relative '../../spec_helper'
require 'spectrum/entities/item'
require 'httparty'
require 'spectrum/request/get_this'
require 'spectrum/available_online_holding'

describe Spectrum::Entities::Item do
  subject do
    holding = YAML.load_file(File.expand_path('../../holding.yml', __FILE__))
    described_class.for_barcode(holding[0][holding[1]], holding[1], holding[2])
  end

  context '#id' do
    it 'returns a string' do
      expect(subject.id).to eq('003553756')
    end
  end
  context '#doc_id' do
    it 'returns a string' do
      expect(subject.doc_id).to eq('003553756')
    end
  end

  context '#callnumber' do
    it 'returns a string' do
      expect(subject.callnumber).to eq('')
    end
  end
  context '#description' do
    it 'returns a string' do
      expect(subject.description).to eq('')
    end
  end
  context '#temp_location?' do
    it 'returns a boolean' do
      expect(subject.temp_location?).to eq(false)
    end
  end

  context '#temp_location' do
    it 'returns a string' do
      expect(subject.temp_location).to eq('')
    end
  end


  context '#status' do
    it 'returns a string' do
      expect(subject.status).to eq('On shelf')
    end
  end

  context '#location' do
    it 'returns a string' do
      expect(subject.location).to eq('HATCH,GRAD')
    end
  end

  context '#notes' do
    it 'returns a string' do
      expect(subject.notes).to eq('')
    end
  end

  context '#issue' do
    it 'returns a string' do
      expect(subject.issue).to eq('')
    end
  end

  context '#can_book?' do
    it 'returns a boolean' do
      expect(subject.can_book?).to be(false)
    end
  end

  context '#can_reserve?' do
    it 'returns a boolean' do
      expect(subject.can_reserve?).to be(false)
    end
  end

  context '#can_request?' do
    it 'returns a boolean' do
      expect(subject.can_request?).to be(true)
    end
  end

  context '#circulating?' do
    it 'returns a boolean' do
      expect(subject.circulating?).to be(true)
    end
  end

  context '#on_shelf?' do
    it 'returns a boolean' do
      expect(subject.on_shelf?).to be(true)
    end
  end

  context '#on_site?' do
    it 'returns a boolean' do
      expect(subject.on_site?).to be(true)
    end
  end

  context '#off_site?' do
    it 'returns a boolean' do
      expect(subject.off_site?).to be(false)
    end
  end
end
describe Spectrum::Entities::Item, 'self.for_get_this' do
  before(:each) do
    @data, @record, @barcode = YAML.load_file(File.expand_path('../../holding.yml', __FILE__))
    @request_dbl = instance_double(Spectrum::Request::GetThis, id: @record, username: nil, barcode: @barcode)
    @source_dbl = double('Source', holdings: 'http://mirlyn_url/getHoldings.pl?id=')
    
  end
  subject do
    described_class.for_get_this(request: @request_dbl, source: @source_dbl)
  end

  it "returns loaded item for valid barcode" do
    stub_request(:get, "#{@source_dbl.holdings}#{@record}").to_return(body: @data.to_json, status: 200, headers: {content_type: 'application/json'})
    expect(subject.barcode).to eq(@barcode)
    expect(subject.class.name).to eq('Spectrum::Entities::Item')
  end

  it "returns AvailabileOnlineHolding when barcode is 'available-online'" do
    allow(@request_dbl).to receive(:barcode).and_return('available-online')
    expect(subject.class.name).to eq('Spectrum::AvailableOnlineHolding')
  end
end

