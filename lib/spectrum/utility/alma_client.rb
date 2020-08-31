require 'httparty'

module Spectrum
  module Utility
    class AlmaClient 
      include HTTParty
      base_uri "#{ENV.fetch('ALMA_API_HOST')}/almaws/v1"
      def initialize
        self.class.headers 'Authorization' => "apikey #{ENV.fetch('ALMA_API_KEY')}"
        self.class.headers 'Accept' => 'application/json'
      end


      def get(*args, &block)
        self.class.get(*args, &block)
      end
      private
      def headers

      end
    end
  end
end
