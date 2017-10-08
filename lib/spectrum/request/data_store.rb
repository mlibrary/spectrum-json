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

      def search_only?
        false
      end

      def available_online?
        false
      end

      def search_only?
        false
      end

      def holdings_only?
        false
      end

      def exclude_newspapers?
        false
      end

      def is_scholarly?
        false
      end

    end
  end
end

