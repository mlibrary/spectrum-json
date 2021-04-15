# frozen_string_literal: true

require_relative '../spec_helper'

describe Spectrum::BibRecord do
  subject do
    described_class.new(JSON.parse(File.read('./spec/fixtures/solr_bib_alma.json')))
  end

  context '#title' do
    it 'returns a string' do
      expect(subject.title).to eq('Enhancing faculty careers : strategies for development and renewal /')
    end
  end

  context '#issn' do
    it 'returns a string' do
      expect(subject.issn).to eq('')
    end
  end

  context '#isbn' do
    it 'returns a string' do
      expect(subject.isbn).to eq('9781555422103')
    end
  end

  context '#bib.accession_number' do
    it 'returns a string' do
      expect(subject.accession_number).to eq('<accession_number>20758549</accession_number>')
    end
  end

  context '#author' do
    it 'returns a string' do
      expect(subject.author).to eq('Schuster, Jack H.')
    end
  end

  context '#date' do
    it 'returns a string' do
      expect(subject.date).to eq('1990')
    end
  end

  context '#pub' do
    it 'returns a string' do
      expect(subject.pub).to eq('Jossey-Bass Publishers')
    end
  end

  context '#place' do
    it 'returns a string' do
      expect(subject.place).to eq('San Francisco ')
    end
  end

  context '#edition' do
    it 'returns a string' do
      expect(subject.edition).to eq('1st ed.')
    end
  end

  context '#callnumber' do
    it 'returns a string' do
      expect(subject.callnumber).to eq('LB 2331.72 .S371 1990')
    end
  end
  context '#restriction' do
    it 'returns a string' do
      expect(subject.restriction).to eq('')
    end
  end
  context '#pub_date' do
    it 'returns a string' do
      expect(subject.pub_date).to eq('')
    end
  end
  context '#publisher' do
    it 'returns a string' do
      expect(subject.publisher).to eq('San Francisco : Jossey-Bass Publishers, 1990.')
    end
  end
  context '#physical_description' do
    it 'returns a string' do
      expect(subject.physical_description).to eq('xxiv, 346 p. : ill. ; 24 cm')
    end
  end
  context '#genre' do
    it 'returns a string' do
      expect(subject.genre).to be_nil
    end
  end
  context '#sgenre' do
    it 'returns a string or nil' do
      expect(subject.sgenre).to be_nil
    end
  end
  context '#fmt' do
    it 'returns a string' do
      expect(subject.fmt).to eq("")
    end
  end
  context '#physical_only?' do
    it 'returns a boolean' do
      expect(subject.physical_only?).to eq(true)
    end
  end

end
