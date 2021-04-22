# frozen_string_literal: true

module Spectrum
  module Response
    class Holdings
      def initialize(source, request, 
                     bib_record: BibRecord.fetch(id: request.id, url: source.url),
                     getHoldingsResponse: HTTParty.get("#{source.holdings}#{request.id}"),
                     holding_factory: lambda{|input| Spectrum::Presenters::HoldingPresenter.for(input)}
                    )
        @request = request
        @bib_record = bib_record

        if getHoldingsResponse.code == 200
          @holdings = getHoldingsResponse[@request.id]
        else
          @holdings = []
        end
        @holding_factory = holding_factory
        @data = process_response
      end

      def renderable
        @data
      end

      private

      def process_response
        data = []
        sorter = Hash.new { |hash, key| hash[key] = key }.tap do |hash|
          hash[nil] = 'AAAA'
          hash['HathiTrust Digital Library'] = 'AAAA'
          hash['- Offsite Shelving -'] = 'zzzz'
        end
        @holdings.each do |item|
          input = HoldingInput.new(holding: item, id: @request.id, bib_record: @bib_record, raw: @holdings)
          holding = @holding_factory.call(input)
          if item['down_links'] || item['up_links'] || (item['item_info'] && item['item_info'].length > 0)
            data << holding.to_h          
          end
        end
        data = data.reject do |item|
          !item.has_key?(:rows) || item[:rows].empty?
        end.sort_by do |item|
          sorter[item[:caption]]
        end
        expanded = @bib_record.physical_only? && data.length == 1
        data.each do |item|
          item[:preExpanded] = expanded
        end
      end
      
      class HoldingInput
        attr_reader :holding, :id, :bib_record, :raw
        def initialize(holding:, id:, bib_record:, raw:)
          @holding = holding
          @id = id
          @bib_record = bib_record
          @raw = raw #raw getHoldings.pl output
        end
      end
      
      private_constant :HoldingInput
    end
  end
end
