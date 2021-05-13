module Spectrum
  class Holding
    class Action

      attr_reader :doc_id, :bib_record, 
      def self.for(bib_record:, item:)

        args = { bib_record: bib_record, item: item }

        if RequestThisAction.match?(item)
          RequestThisAction.new(**args)
        elsif BookThisAction.match?(item)
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
