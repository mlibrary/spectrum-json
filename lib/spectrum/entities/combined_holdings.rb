module Spectrum::Entities
  class CombinedHoldings
    attr_reader :holdings
    #alma and hathi holdings
    extend Forwardable
    def_delegators :@alma_holdings, :find_item

    def initialize(alma_holdings:,hathi_holding:)
      @alma_holdings = alma_holdings
      @hathi_holding = hathi_holding
      @holdings = [@hathi_holding, *@alma_holdings]
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
