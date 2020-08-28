require_relative '../../spec_helper'
require 'spectrum/utility/bib_fetcher'
require 'spectrum/bib_record'
require 'rsolr'

describe Spectrum::Utility::BibFetcher, "item(request:)" do
  it "returns BibRecord for id and url" do
    rsolr_client = double( 'RSolr.connect', get: 'mybib')

    allow(RSolr).to receive(:solr_escape)
    allow(RSolr).to receive(:connect).and_return(rsolr_client)
    allow(Spectrum::BibRecord).to receive(:new).and_return('Spectrum::BibRecord')

    expect(rsolr_client).to receive(:get)

    bib = described_class.new().fetch(id: '12345', url: 'myurl')
    expect(bib).to eq('Spectrum::BibRecord')
  end
end
