require 'spectrum/policy/get_this'

class PatronStub
  def empty?
    true
  end
  def expired?
  end
  def active?
  end
end

class RecordStub
  def on_site?
  end
end

describe Spectrum::Policy::GetThis::Option do
  subject do
    described_class.new('label' => 'Label', 'description' => 'Description', 'faq' => 'FAQ', 'grants' => [])
  end

  describe '#to_h' do
    it 'returns a hash' do
      expect(subject.to_h).to eq({'label' => 'Label', 'description' => 'Description', 'faq' => 'FAQ'})
    end
  end
end

describe Spectrum::Policy::GetThis do
  let(:patron) do
    PatronStub.new
  end
  let(:record) do
    RecordStub.new
  end

  subject do
    described_class.load_config(File.expand_path("../../../get_this_policy.yml", __FILE__))
    described_class.new(patron, record)
  end

  describe "::load_config(config_file)" do
    it "loads a yaml file" do
      described_class.load_config(File.expand_path("../../../get_this_policy.yml", __FILE__))
      expect(described_class.options.length).to eq(10)
    end
  end

  describe '#resolve' do
    it 'maps patron type' do
      expect(subject.resolve.length).to eq(1)
    end
  end
end
