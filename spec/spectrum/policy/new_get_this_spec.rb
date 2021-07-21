require_relative '../../spec_helper.rb'

describe Spectrum::Policy::GetThis do
  before do
    described_class.load_config(YAML.load('./spec/fixtures/get_this_policy.yml'))
    @patron = JSON.parse(File.read('./spec/fixtures/alma_user_0.json'))
  end
  subject do
    patron = Spectrum::Entities::AlmaUser.new(data: @patron)
    bib = Spectrum::BibRecord.new(JSON.parse(File.read('./spec/fixtures/ice_cream.json')))
    holdings = Spectrum::Entities::AlmaHoldings.new(alma:{}, solr: bib)
    item = holdings.find_item('39015087908490')
    decorated_item = Spectrum::Decorators::PhysicalItemDecorator.new(item)
    described_class.new(patron, bib, decorated_item)
  end
  it "resolve has expected output" do
    resolved = subject.resolve
    output =  JSON.parse(File.read('./spec/fixtures/get_this_contactless_doc_del.json'))["options"]
    expect(resolved).to eq(output)
  end
end
