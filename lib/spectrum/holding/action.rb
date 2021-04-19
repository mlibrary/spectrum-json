module Spectrum
  class Holding
    class Action

      attr_reader :id, :datastore, :bib, :item, :info
      def self.for(*args)
        if RequestThisAction.match?(*args)
          RequestThisAction.new(*args)
        elsif BookThisAction.match?(*args)
          BookThisAction.new(*args)
        elsif GetThisAction.match?(*args)
          GetThisAction.new(*args)
        else
          Action.new(*args)
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

      def initialize(id, datastore, bib, item, info)
        @id = id
        @datastore = datastore
        @bib = bib
        @item = item
        @info = info
      end

      def finalize
        { text: label }
      end
    end
  end
end
