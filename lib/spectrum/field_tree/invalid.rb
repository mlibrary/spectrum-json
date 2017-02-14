module Spectrum
  module FieldTree
    class Invalid < RuntimeError

      def query(field_map = {})
        ''
      end

      def valid?
        false
      end
    end
  end
end

