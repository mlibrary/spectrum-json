require_relative '../../spec_helper'
describe Spectrum::Entities::AlmaUser do

  context "alma_user_0" do
    subject do
      response = JSON.parse(File.read('./spec/fixtures/alma_user_0.json'))
      described_class.new(data: response)
    end

    it "isn't #empty?" do
      expect(subject.empty?).to be(false)
    end

    it "isn't #_flint?" do
      expect(subject.flint?).to be(false)
    end

    it "isn't #can_other?" do
      expect(subject.can_other?).to be(false)
    end

    it 'is #active?' do
      expect(subject.active?).to be(true)
    end

    it 'is #ann_arbor?' do
      expect(subject.ann_arbor?).to be(true)
    end

    it '#can_ill?' do
      expect(subject.can_ill?).to be(true)
    end

    it "has an id" do
      expect(subject.id).to eq("PRIMARY_ID_0")
    end

    it "has a name" do
      expect(subject.name).to eq("FNAME LNAME")
    end

    it "has an email" do
      expect(subject.email).to eq("user0@example.com")
    end

    it 'has sms' do
      expect(subject.sms).to eq("5555555555")
    end
  end
  context "alma_user_1" do
    subject do
      response = JSON.parse(File.read('./spec/fixtures/alma_user_1.json'))
      described_class.new(data: response)
    end

    it "isn't #can_ill?" do
      expect(subject.can_ill?).to be(false)
    end

    it "isn't #active?" do
      expect(subject.active?).to be(false)
    end

    it "#can_other?" do
      expect(subject.can_other?).to be(true)
    end

    it "is #flint?" do
      expect(subject.flint?).to be(true)
    end

  end
end
