# frozen_string_literal: true

module Spectrum
  module Response
    class Holdings
      def initialize(source, request, 
                     #bib_record: BibRecord.fetch(id: request.id, url: source.url),
                     holdings: Spectrum::Entities::CombinedHoldings.for(source, request),
                     holding_factory: lambda{|input| Spectrum::Presenters::HoldingPresenter.for(input)}
                    )
        @holdings = holdings
        @bib_record = holdings.bib_record

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
        @holdings.each do |holding|
          input = HoldingInput.new(holding: holding, bib_record: @bib_record)
          holding_presenter = @holding_factory.call(input)
          if holding_presenter.class.to_s.match?(/LinkedHolding/) || holding.items.count > 0
            data << holding_presenter.to_h          
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
        attr_reader :holding, :bib_record 
        def initialize(bib_record:, holding: nil )
          @holding = holding 
          @bib_record = bib_record
        end
      end
      
      private_constant :HoldingInput
    end
  end
end
