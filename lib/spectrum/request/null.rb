module Spectrum
  module Request
    class Null
      def spectrum
        nil
      end

      def can_sort?
        false
      end

      def search_only?
        false
      end

      def available_online?
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

