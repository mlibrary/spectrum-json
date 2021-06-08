# frozen_string_literal: true

require_relative '../spec_helper'

describe Spectrum::BibRecord do
  before(:each) do
    @solr_bib_alma = File.read('./spec/fixtures/solr_bib_alma.json')
  end
  subject do
    described_class.new(JSON.parse(@solr_bib_alma))
  end

  context '#mms_id' do
    it "returns a string" do
      expect(subject.mms_id).to eq('990020578280206381')
    end
  end
  #needs to have bib Holdings.
  context '#holdings' do
    it "returns an array" do
      expect(subject.holdings.class.name).to eq('Array')
    end
    context "alma holding" do
      let(:alma_holding) { subject.holdings.first }
      it "has a library" do
        expect(alma_holding.library).to eq('HATCH')
      end
      it "has a location" do
        expect(alma_holding.location).to eq('GRAD')
      end
      it "has a callnumber" do
        expect(alma_holding.callnumber).to eq('LB 2331.72 .S371 1990')
      end
      it "has a public_note" do
        expect(alma_holding.public_note).to be_nil
      end
      it "has items" do
        expect(alma_holding.items.count).to eq(1)
      end
    end

    context "#alma_holding(holding_id)" do
      it "returns the alma holding for a given holding id" do
        expect(subject.alma_holding("2297537770006381").callnumber).to eq('LB 2331.72 .S371 1990')  
      end
      it "returns nil for no matching holding" do
        expect(subject.alma_holding("not_a_holding_id")).to be_nil
      end
    end
    context "an alma holding" do
      let(:alma_holding) { subject.holdings[0] }
      ['holding_id', 'location', 'callnumber', 'public_note', 'items', 'summary_holdings'].each do |method|
        context "##{method}" do
          it "respond_to? #{method}" do
            expect(alma_holding.respond_to?(method)).to be(true)
          end
        end
      end
    end
    context "an alma item" do
      let(:alma_item){ subject.holdings[0].items[0] }
      ['library','location','description','public_note','barcode',
      'item_policy','process_type','permanent_location','permanent_library',
      'id','temp_location?','callnumber'].each do |method|
        context "##{method}" do
          it "respond_to? #{method}" do
            expect(alma_item.respond_to?(method)).to be(true)
          end
        end
      end
    end
    context "#physical_holdings?" do
      it "returns true for if there are physical holdings" do
        expect(subject.physical_holdings?).to eq(true)
      end
      it "returns false for only holdings with library ELEC" do
        @solr_bib_alma = @solr_bib_alma.gsub(/HATCH/, 'ELEC')
        expect(subject.physical_holdings?).to eq(false)
      end
    end
    context "#hathi_holding" do
      it "returns a HathiHolding item" do
        expect(subject.hathi_holding.class.name.to_s).to eq("Spectrum::BibRecord::HathiHolding")
      end
      it "returns nil for no Hathi Item" do
        @solr_bib_alma = @solr_bib_alma.gsub(/HathiTrust/, 'SomeOtherTrust')
        expect(subject.hathi_holding).to be_nil
      end
    end
    context "hathi holding" do
      let(:hathi_holding) { subject.holdings[1] }
      it "has a library" do
        expect(hathi_holding.library).to eq("HathiTrust Digital Library")
      end
      it "has items" do
        expect(hathi_holding.items.count).to eq(1)
      end
      context "hathi item" do
        let(:hathi_item) { hathi_holding.items[0] }

        it "has an id" do
          expect(hathi_item.id).to eq("mdp.39015017893416")
        end
        it "has rights" do
          expect(hathi_item.rights).to eq("ic")
        end
        it "has a description" do
          expect(hathi_item.description).to eq("")
        end
        it "has a collection_code" do
          expect(hathi_item.collection_code).to eq("MIU")
        end
        it "has access boolean" do
          expect(hathi_item.access).to eq(0)
        end
        it "has a source" do
          expect(hathi_item.source).to eq("University of Michigan")
        end
        it "has a status" do
          expect(hathi_item.status).to eq("Full text available, simultaneous access is limited (HathiTrust log in required)")
        end
      end
    end

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
