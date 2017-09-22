module Spectrum
  module Request
    class DataStore
      include Requesty

      def facet_uid
        nil
      end

      def facet_sort
        nil
      end

      def facet_offset
        nil
      end

      def facet_limit
        500
      end

    end
  end
end

