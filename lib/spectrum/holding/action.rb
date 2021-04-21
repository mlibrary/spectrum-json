module Spectrum
  class Holding
    class Action

      attr_reader :id, :doc_id, :datastore, :bib, :item, :info
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
        @id = doc_id
        @datastore = doc_id
        @bib = bib_record
        @item = holding
        @info = item_info
      end

      def finalize
        { text: label }
      end
    end
  end
end
