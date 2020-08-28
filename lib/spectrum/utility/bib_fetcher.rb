#calls solr; fetches a bib
require 'rsolr'

module Spectrum
  module Utility
    class BibFetcher
      def fetch(id:, url:)
        client = RSolr.connect(url: url) 
        BibRecord.new(client.get('select', params: { q: "id:#{RSolr.solr_escape(id)}" }))
      end
    end
  end
end 
