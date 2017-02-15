module Spectrum
  module Request
    class Record

      def initialize(request)
        @request = request
        @query = "#{@request.params['id_field']}:#{@request.params['id']}"
      end

      def sort
      end

      def slice
        [0, 1]
      end

      def query(query_map = {}, filter_map = {})
        {
          q: @query,
          page: 0,
          start: 0,
          rows: 1,
          fq: [],
          per_page: 1,
        }
      end

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
        nil
      end

      def fvf(_)
        nil
      end

    end
  end
end

