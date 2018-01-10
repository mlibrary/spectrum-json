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

class AuthenticatedPatronStub
  def empty?
    false
  end

  def expired?
    false
  end

  def active?
    true
  end

  def id
    'authenticated_patron'
  end

  def name
    'Authenticated Patron'
  end
end

class RecordStub
  def on_site?
    true
  end
  def on_shelf?
    true
  end
  def circulating?
    true
  end

  def id
    '000000000'
  end
  def barcode
    '00000000000'
  end
end

describe Spectrum::Policy::GetThis::Option do
  subject do
    described_class.new(
      'label' => 'Label',
      'description' => 'Description',
      'duration' => 'Duration',
      'faq' => 'FAQ',
      'grants' => [],
      'tip' => 'tip',
      'form' => 'form'
    )
  end

  describe '#to_h' do
    it 'returns a hash' do
      expect(subject.to_h).to eq({
        'label' => 'Label',
        'description' => 'Description',
        'duration' => 'Duration',
        'faq' => 'FAQ',
        'tip' => 'tip',
        'form' => 'form'
      })
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

  let(:authenticated_patron) do
    AuthenticatedPatronStub.new
  end

  before do
    described_class.load_config(File.expand_path("../../../get_this_policy.yml", __FILE__))
  end

  let(:authenticated_subject) do
    described_class.new(authenticated_patron, record)
  end

  subject do
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
      expect(subject.resolve.length).to eq(2)
    end

    it 'fills in placeholders' do
      expect(authenticated_subject.resolve[1]['form']['action']).to eq("https://mirlyn.lib.umich.edu/Record/000000000/Hold")
    end
  end
end
