require 'marc'

module Spectrum
  class BibRecord
    def initialize(solr_response)
      @data = extract_data(solr_response)
      @fullrecord = MARC::XMLReader.new(StringIO.new(@data['fullrecord'])).first
    end

    def title
      @fullrecord['245'].select do |subfield|
        /[abdefgknp]/ === subfield.code 
      end.map(&:value).join(' ')
    end

    def callnumber
      fetch_first('callnumber')
    end

    def issn
      candidate = fetch_first('issn')
      if candidate.empty? && fetch_first('isbn').empty?
        'N/A'
      else
        candidate
      end
    end

    def isbn
      fetch_first('isbn')
    end

    def edition
      fetch_first('edition')
    end

    def author
      fetch_joined('mainauthor', '; ')
    end

    def accession_number
       "<accession_number>#{fetch_joined('oclc', ',')}</accession_number>"
    end

    def date
      #fetch_first('display_date')
      clean_marc(@fullrecord['260']['c'])
    end

    def pub
      #fetch_first('publisher')
      clean_marc(@fullrecord['260']['b'])
    end

    def place
      #fetch_first('pubPlace')
      clean_marc(@fullrecord['260']['a'])
    end

    private
    def extract_data(solr_response)
      solr_response['response']['docs'].first
    end

    def fetch_first(key)
      fetch_list(key).first || ''
    end

    def fetch_joined(key, string = ', ')
      fetch_list(key).join(string)
    end

    def fetch_list(key)
      Array(@data[key])
    end

    def clean_marc(str)
      str.respond_to?(:sub) ? str.sub(/[.,;:\/]$/,'') : ''
    end
  end
end
