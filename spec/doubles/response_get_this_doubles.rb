module Spectrum
  module AvailableOnlineHolding
  end
  module Utility
    class HttpClient
    end
    class Solr
    end
  end
  module Policy
    class GetThis
      attr_reader :account, :bib, :item
      def initialize(account, bib, item)
        @account = account
        @bib = bib
        @item = item
      end
     
      def resolve
        self
      end
    end
  end
  class Holding
    def initialize(holdings, id, barcode)
    end
  end
  class BibRecord
    attr_reader :solr_response
    def initialize(solr_response)
      @solr_response = solr_response
    end
  end
end

module Aleph
  class Borrower
  end
  class Error
  end
end


class RSolr
end
