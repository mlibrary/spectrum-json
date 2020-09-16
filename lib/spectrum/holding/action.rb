module Spectrum
  class Holding
    class Action

      class << self
        def new(*args)
          klass = get_class(*args)
          return klass.new(*args) if klass
          obj = allocate
          obj.send(:initialize, *args)
          obj
        end

        def inherited(base)
          registry << base
        end

        def label(l = nil)
          @label = l if l
          @label
        end

        def match?(*args)
          false
        end

        private

        def registry
          @registry ||= []
        end

        def get_class(*args)
          registry.find { |klass| klass.match?(*args) }
        end
      end

      attr_reader :id, :datastore, :bib, :item, :info

      label 'N/A'

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
