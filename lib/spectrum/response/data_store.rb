module Spectrum
  module Response
    class DataStore

      def initialize(args = {})
        @data = args[:data] || []
        @base_url = args[:base_url] || 'http://localhost'
      end

      def facet(name)
        @data.facet(name, @base_url)
      end

      def spectrum
        @data.spectrum(@base_url + '/')
      end
    end
  end
end
