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

  context '#inventory_number' do
    it 'returns a string' do
      expect(subject.inventory_number).to eq('11111')
    end
  end

  context '#library' do
    it 'returns a string' do
      expect(subject.library).to eq('MUS')
    end
  end
  context '#description' do
    it 'returns a string' do
      expect(subject.description).to eq('description')
    end
  end
  context '#collection' do
    it 'returns a string' do
      expect(subject.collection).to eq('OVR')
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
