require 'json'
require 'net/http'

module Spectrum
  module Utility
    class HttpClient
      def get(uri)
        JSON.parse( URI( Net::HTTP.get(uri) ) )
      end
    end
  end
end
