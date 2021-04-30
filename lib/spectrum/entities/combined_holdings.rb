module Spectrum::Entities
  class CombinedHoldings
    attr_reader :holdings, :bib_record
    #alma and hathi holdings
    extend Forwardable
    def_delegators :@alma_holdings, :find_item

    def initialize(alma_holdings:,hathi_holding:,bib_record:)
      @bib_record = bib_record
      @alma_holdings = alma_holdings
      @hathi_holding = hathi_holding
      @holdings = [@hathi_holding, *@alma_holdings.holdings]
    end

    def self.for_bib(bib_record, 
                 alma_holdings = Spectrum::Entities::AlmaHoldings.new(bib_record.mms_id),
                 hathi_holding = Spectrum::Entities::NewHathiHolding.new(bib_record) )

      Spectrum::Entities::CombinedHoldings.new(alma_holdings: alma_holdings, hathi_holding: hathi_holding, bib_record: bib_record)
      
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
