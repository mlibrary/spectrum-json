#Wrapper for RSolr
require 'rsolr'

module Spectrum
  module Utility
    class Solr
      def connect(**args)
        Rsolr.connect(args)
      end
      def solr_escape(str)
        Rsolr.solr_escape(str)
      end
    end
  end
end
