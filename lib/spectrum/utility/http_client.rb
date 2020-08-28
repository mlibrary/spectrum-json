require 'json'
require 'net/http'

module Spectrum
  module Utility
    class HttpClient
      def get(uri)
        JSON.parse( Net::HTTP.get( URI(uri) ) )
      end
    end
  end
end
