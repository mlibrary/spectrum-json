module Spectrum
  class Holding
    class Action

      attr_reader :doc_id, :bib_record, 
      def self.for(item)

        if NoAction.match?(item)
          NoAction.new(item)
        elsif RequestThisAction.match?(item)
          RequestThisAction.new(item)
        else
          GetThisAction.new(item)
        end
      end

      def self.label
      end

      def self.match?(*args)
      end

      def label
        self.class.label
      end

      def initialize(item)
        @bib_record = bib_record
        @item = item #Spectrum::Entities::MirlynItem
      end

      def finalize
        { text: label }
      end
    end
  end
end
