module Spectrum
  module FieldTree
    class Empty
      def query(field_map = {})
        '*:*'
      end

      def valid?
        true
      end

      def spectrum
        {}
      end

      def params(field_map)
        {}
      end
    end
  end
end
