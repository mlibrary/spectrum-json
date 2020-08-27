require 'httparty'

module Spectrum
  module Utility
    class AlmaClient > HttpClient
      include HTTParty
      base_uri "#{ENV.fetch('ALMA_API_HOST')}/almaws/v1"
      
      private
      def headers
        {
          'Authorization' => "apikey #{ENV.fetch('ALMA_API_KEY')}",
          'accept' => 'application/json'
        }

      end
    end
  end
end
