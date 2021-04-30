module Spectrum::Entities
  class CombinedHoldings
    attr_reader :holdings
    #alma and hathi holdings
    extend Forwardable
    def_delegators :@alma_holdings, :find_item

    def initialize(alma_holdings:,hathi_holding:)
      @alma_holdings = alma_holdings
      @hathi_holding = hathi_holding
      @holdings = [@hathi_holding, *@alma_holdings.holdings]
    end

    def self.for(mms_id, solr_url,
                 alma_holdings = Spectrum::Entities::AlmaHoldings.new(mms_id),
                 hathi_holding = Spectrum::Entities::NewHathiHolding.for(mms_id, solr_url) )

      Spectrum::Entities::CombinedHoldings.new(alma_holdings: alma_holdings, hathi_holding: hathi_holding)
      
    end
    def hathi_holdings
      [@hathi_holding]
    end
  
    def [](index)
      @holdings[index]
    end
    def each(&block)
      @holdings.each(&block)
    end
    def empty?
      @holdings.empty?
    end
  end
end
