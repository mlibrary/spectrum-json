module Spectrum
  class Holding
    class Action

      attr_reader :doc_id, :bib_record, 
      def self.for(bib_record:, item:)

        args = { bib_record: bib_record, item: item }

        if item.can_reserve?
          RequestThisAction.new(**args)
        elsif item.can_book?
          BookThisAction.new(**args)
        elsif GetThisAction.match?(item)
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

      def initialize(bib_record:, item:)
        @bib_record = bib_record
        @item = item #Spectrum::Entities::MirlynItem
      end

      def finalize
        { text: label }
      end
    end
  end
end
