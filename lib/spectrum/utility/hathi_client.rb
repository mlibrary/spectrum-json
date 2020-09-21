require 'httparty'
module Spectrum
  module Utility
    class HathiClient
      def initialize(resolver = HathiResolver.new)
        @resolver = resolver
      end
      def get(oclcs, response_factory = lambda{|x| HathiResponse.new(x)})
        hathi_oclcs = []
        responses = oclcs.map do |oclc|
          next if hathi_oclcs.include? oclc
          response = @resolver.get(oclc)
          if response.code == 200
            response.parsed_response["records"].each_value{|value| hathi_oclcs.push( value["oclcs"] )}
            hathi_oclcs.flatten!
            response.parsed_response 
 
          end
        end
        response_factory.call(responses.compact)
      end
    end

    class HathiResolver
      include HTTParty
      base_uri "https://catalog.hathitrust.org/api/volumes/brief/oclc/"

      def get(oclc) #array of oclc numbers
        self.class.get(oclc)
      end
    end
    
    class HathiResponse
      def initialize(responses)
        #responses: array of responses from HathiTrust OCLC lookups
        @responses = responses
      end
      def oclcs
        oclcs = Array.new
        @responses.each do |resp| 
          resp["records"].each_value{|value| oclcs.push( value["oclcs"] )}
        end
        oclcs.flatten.uniq
      end
      def items
        #array of items
        r = @responses.map{|resp| resp["items"]}.flatten.uniq
      end
      def empty?
        oclcs.empty?
      end
    end
  end
end
