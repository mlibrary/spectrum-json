# collection of Spectrum::Holding objects.
module Spectrum
  class Holdings
    def initialize( 
            source:, 
            request:, 
            client: Spectrum::Utility::AlmaClient.new, 
            bib_record: BibFetcher.new.fetch(id: mms_id, url: source.url),
            alma_holding_factory: lambda {|holding, items, preExpanded| Spectrum::AlmaHolding.new(holding: holding, items: items, preExpanded: preExpanded)},
            hathi_fetcher: Spectrum::Utility::HathiHoldingFetcher.new,
            hathi_holding_factory: lambda {|holding, preExpanded| Spectrum::HathiHolding.new(holding: holding, preExpanded: preExpanded)}
        )
      @bib_record = bib_record
      @mms_id = request.id

      @client = client
      @alma_holding_factory = alma_holding_factory
      @full_alma_holdings = get_full_alma_holdings

      @hathi_fetcher = hathi_fetcher
      @hathi_holding_factory = hathi_holding_factory
      @hathi_holdings_response = get_hathi_holdings_response
    end

    def to_a
      holdings.map{|holding| holding.to_h}
    end
    
    def preExpanded
      @bib_record.physical_only? && (alma_holding_count + hathi_holding_count) == 1   
    end
    def holdings
      sorter = Hash.new { |hash, key| hash[key] = key }.tap do |hash|
        hash[nil] = 'AAAA'
        hash['HathiTrust Digital Library'] = 'AAAA'
        hash['- Offsite Shelving -'] = 'zzzz'
      end

      [alma_holdings, hathi_holdings].flatten.compact.sort_by do |holding|
        sorter[holding.caption]  
      end

    end

    private
    def alma_holdings
      @full_alma_holdings.map{|h| @alma_holding_factory.call(h.holding, h.items, preExpanded) }
    end
    def hathi_holdings
      if hathi_holding_count == 1
        @hathi_holding_factory.call(@hathi_holdings_response, preExpanded) 
      else
        nil
      end
    end
    def get_hathi_holdings_response
      @hathi_fetcher.get(@bib_record.oclc) 
    end
    def hathi_holding_count
      @hathi_holdings_response["items"].empty? ? 0 : 1
    end
    def alma_holding_count
      @full_alma_holdings.count
    end
    def get_full_alma_holdings
      alma_holdings_ids.map do |holding_id|
        fullHolding = FullAlmaHolding.new(@mms_id, holding_id, @client) 
      end
    end

    def alma_holdings_ids
      response = @client.get("/bibs/#{@mms_id}/holdings")
      if response.code == 200 && response.parsed_response["total_record_count"] > 0
        response.parsed_response["holding"].map{|h| h["holding_id"]}
      else
        []
      end
    end
    class FullAlmaHolding
      attr_reader :holding, :items
      def initialize(mms_id, holding_id, client)
        @mms_id = mms_id
        @holding_id = holding_id
        @client = client
        @holding = get_holding
        @items = get_items
      end

      def present?
        !@holding.empty?
      end
      private

      def get_holding
        response = @client.get("/bibs/#{@mms_id}/holdings/#{@holding_id}")
        if response.code == 200
          response.parsed_response
        else
          {}
        end
      end
      def get_items # FIXME need to deal with more than 100 items
        response = @client.get("/bibs/#{@mms_id}/holdings/#{@holding_id}/items")
        if response.code == 200 
          response.parsed_response["item"]
        else
          []
        end
      end
    end
    private_constant :FullAlmaHolding

  end
  
end
