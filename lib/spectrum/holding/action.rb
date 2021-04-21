module Spectrum
  class Holding
    class Action

      attr_reader :doc_id, :bib_record, :holding, :item_info
      def self.for(**args)
        if RequestThisAction.match?(args[:item_info])
          RequestThisAction.new(**args)
        elsif BookThisAction.match?(args[:item_info])
          BookThisAction.new(**args)
        elsif GetThisAction.match?(bib_record: args[:bib_record], item: args[:holding], info: args[:item_info])
          GetThisAction.new(**args)
        else
          Action.new(**args)
        end
      end

      def self.label
        'N/A'
      end

      def self.match?(*args)
        false
      end

      def label
        self.class.label
      end

      def initialize(doc_id:, bib_record:, holding:, item_info:)
        @doc_id = doc_id

        @bib_record = bib_record
        
        @holding = holding

        @item_info = item_info
      end

      def finalize
        { text: label }
      end
    end
  end
end
