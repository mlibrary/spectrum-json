require 'httparty'
module Spectrum
  module Utility
    class HathiHoldingFetcher
      include HTTParty
      base_uri "https://catalog.hathitrust.org/api/volumes/brief/oclc/"

      def get(oclc) #array of oclc numbers
        #returns appropriate hathi holding response
      end
    end
  end
end
