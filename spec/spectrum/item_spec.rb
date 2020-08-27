# frozen_string_literal: true

require_relative '../spec_helper'
require 'spectrum/item'

describe Spectrum::Item do
  subject do
    described_class.new(JSON.parse(File.read('./spec/fixtures/plain_words_on_singing_item.json')))
  end

  context '#barcode' do
    it 'returns a string' do
      expect(subject.barcode).to eq('0919242913')
    end
  end
  context '#record' do
    it 'returns a string of mms_id (was doc_id)' do
      expect(subject.record).to eq('991408490000541')
    end
  end
  context '#id' do
    it 'returns a string of mms_id (was doc_id)' do
      expect(subject.id).to eq('991408490000541')
    end
  end

  context '#callnumber' do
    it 'returns a string' do
      expect(subject.callnumber).to eq('MT820 .S53')
    end
  end

  #context '#status' do
    #it 'returns a string' do
      #expect(subject.status).to eq('On shelf')
    #end
  #end

  context '#location' do
    it 'returns a string' do
      expect(subject.location).to eq('MUS,OVR')
    end
  end

  #context '#notes' do
    #it 'returns a string' do
      #expect(subject.notes).to eq('')
    #end
  #end

  #context '#issue' do
    #it 'returns a string' do
      #expect(subject.issue).to eq('')
    #end
  #end
  1
  context '#full_item_key' do
    it 'returns a string' do
      expect(subject.full_item_key).to eq('235561180000541')
    end
  end

  #context '#can_book?' do
    #it 'returns a boolean' do
      #expect(subject.can_book?).to be(false)
    #end
  #end

  #context '#can_reserve?' do
    #it 'returns a boolean' do
      #expect(subject.can_reserve?).to be(false)
    #end
  #end

  #context '#can_request?' do
    #it 'returns a boolean' do
      #expect(subject.can_request?).to be(true)
    #end
  #end

  #context '#circulating?' do
    #it 'returns a boolean' do
      #expect(subject.circulating?).to be(true)
    #end
  #end

  context '#on_shelf?' do
    it 'returns a boolean' do
      expect(subject.on_shelf?).to be(false)
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
  context '#reopened?' do
    it 'returns a boolean' do
      expect(subject.reopened?).to be(false)
    end
  end
end

describe Spectrum::Item, "self.for(barcode:)" do
  before(:each) do
    @client_dbl = double('Spectrum::Utility::HttpClient')
  end
  it "returns loaded item for valid barcode" do
    response_dbl = double('HTTParty::Response', parsed_response: JSON.parse(File.read('./spec/fixtures/plain_words_on_singing_item.json')), code: 200 )
    allow(@client_dbl).to receive(:get).and_return(response_dbl)
    item = described_class.for(barcode: '0919242913', client: @client_dbl)
    expect(item.barcode).to eq('0919242913')
    expect(item.class.name).to eq('Spectrum::Item')
  end

  it "returns NullItem for error received" do
    response_dbl = double('HTTParty::Response', parsed_response: JSON.parse(File.read('./spec/fixtures/item_error.json')), code: 400 )
    allow(@client_dbl).to receive(:get).and_return(response_dbl)
    item = described_class.for(barcode: '0919242913', client: @client_dbl)
    expect(item.barcode).to eq('0919242913')
    expect(item.class.name).to eq('Spectrum::NullItem')
  end

end

describe Spectrum::NullItem do
  subject do
    described_class.new('1234')
  end

  context '#barcode' do
    it 'returns a string' do
      expect(subject.barcode).to eq('1234')
    end
  end

  context '#record' do
    it 'returns empty string' do
      expect(subject.record).to eq('')
    end
  end
  context '#id' do
    it 'returns empty string' do
      expect(subject.id).to eq('')
    end
  end

  context '#callnumber' do
    it 'returns a string' do
      expect(subject.callnumber).to eq('')
    end
  end

  context '#status' do
    it 'returns a string' do
      expect(subject.status).to eq('')
    end
  end

  context '#location' do
    it 'returns a string' do
      expect(subject.location).to eq('')
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
  
  context '#full_item_key' do
    it 'returns a string' do
      expect(subject.full_item_key).to eq('')
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
      expect(subject.can_request?).to be(false)
    end
  end

  context '#circulating?' do
    it 'returns a boolean' do
      expect(subject.circulating?).to be(false)
    end
  end

  context '#on_shelf?' do
    it 'returns a boolean' do
      expect(subject.on_shelf?).to be(false)
    end
  end

  #context '#on_site?' do
    #it 'returns a boolean' do
      #expect(subject.on_site?).to be(true)
    #end
  #end

  #context '#off_site?' do
    #it 'returns a boolean' do
      #expect(subject.off_site?).to be(false)
    #end
  #end
  context '#reopened?' do
    it 'returns a boolean' do
      expect(subject.reopened?).to be(false)
    end
  end
end
