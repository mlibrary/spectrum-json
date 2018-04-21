# frozen_string_literal: true

require_relative '../spec_helper'
require 'spectrum/holding'

describe Spectrum::Holding do
  subject do
    described_class.new(*YAML.load_file(File.expand_path('../holding.yml', __FILE__)))
  end

  context '#id' do
    it 'returns a string' do
      expect(subject.id).to eq('003553756')
    end
  end

  context '#callnumber' do
    it 'returns a string' do
      expect(subject.callnumber).to eq('')
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
