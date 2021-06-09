module Spectrum
  class Holding
    class Action

      attr_reader :doc_id, :bib_record, 
      def self.for(bib_record:, item:)

        args = { bib_record: bib_record, item: item }

        if NoAction.match?(item)
          NoAction.new(**args)
        elsif RequestThisAction.match?(item)
          RequestThisAction.new(**args)
        else
          GetThisAction.new(**args)
        end
      end

      def self.label
      end

      def self.match?(*args)
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
