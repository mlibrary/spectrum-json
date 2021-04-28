# frozen_string_literal: true
class PatronStub
  def empty?
    true
  end

  def expired?; end

  def active?; end

  def method_missing(_symbol, *_args)
    ''
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

  def method_missing(symbol, *_args)
    symbol.to_s
  end
end

class BibStub
  def method_missing(symbol, *_args)
    symbol.to_s
  end
end

class ItemStub
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

  def method_missing(_symbol, *_args)
    ''
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
      expect(subject.to_h).to eq(
        'label' => 'Label',
        'description' => 'Description',
        'duration' => 'Duration',
        'orientation' => '',
        'faq' => 'FAQ',
        'tip' => 'tip',
        'form' => 'form',
        'service_type' => nil
      )
    end
  end
end

describe Spectrum::Policy::GetThis do
  let(:patron) do
    PatronStub.new
  end

  let(:bib) do
    BibStub.new
  end

  let(:item) do
    ItemStub.new
  end

  let(:authenticated_patron) do
    AuthenticatedPatronStub.new
  end

  before do
    described_class.load_config(File.expand_path('../../../get_this_policy.yml', __FILE__))
  end

  let(:authenticated_subject) do
    described_class.new(authenticated_patron, bib, item)
  end

  subject do
    described_class.new(patron, bib, item)
  end

  describe '::load_config(config_file)' do
    it 'loads a yaml file' do
      described_class.load_config(File.expand_path('../../../get_this_policy.yml', __FILE__))
      expect(described_class.options.length).to eq(10)
    end
  end

  describe '#resolve' do
    it 'maps patron type' do
      expect(subject.resolve.length).to eq(2)
    end

    it 'fills in placeholders' do
      expect(authenticated_subject.resolve[1]['form']['action']).to eq('https://mirlyn.lib.umich.edu/Record/000000000/Hold')
    end
  end
end
