require_relative '../spec_helper'
require 'spectrum/bib_record'

describe Spectrum::BibRecord do
  subject do
    described_class.new(YAML.load_file(File.expand_path('../bib_record.yml', __FILE__)))
  end

  context '#title' do
    it "returns a string" do
      expect(subject.title).to eq('The materials of aircraft construction, for the designer, user and student of aircraft and aircraft engines,')
    end
  end

  context '#issn' do
    it 'returns a string' do
      expect(subject.issn).to eq('N/A')
    end
  end

  context '#isbn' do
    it 'returns a string' do
      expect(subject.isbn).to eq('')
    end
  end

  context '#bib.accession_number' do
    it 'returns a string' do
      expect(subject.accession_number).to eq('<accession_number>03935616</accession_number>')
    end
  end

  context '#author' do
    it 'returns a string' do
      expect(subject.author).to eq('Hill, Frederick Thomas, 1886-')
    end
  end

  context '#date' do
    it 'returns a string' do
      expect(subject.date).to eq('1940')
    end
  end

  context '#pub' do
    it 'returns a string' do
      expect(subject.pub).to eq('Sir I. Pitman & sons, ltd.')
    end
  end

  context '#place' do
    it 'returns a string' do
      expect(subject.place).to eq('London')
    end
  end

  context '#edition' do
    it 'returns a string' do
      expect(subject.edition).to eq('4th and rev. ed.')
    end
  end

  context '#callnumber' do
    it 'returns a string' do
      expect(subject.callnumber).to eq('TL 698 .H64 1940')
    end
  end

end
