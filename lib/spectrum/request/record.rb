module Spectrum
  module Request
    class Record

      def initialize(request)
        @request = request
        @tree    = Spectrum::FieldTree.new({
          'type' => 'field',
          'value' => @request.params['id_field'],
          'children' => [{
            'type' => 'literal',
            'value' => @request.params['id']
          }]
        })
      end

      def sort
      end

      def slice
        [0, 1]
      end

      def query(query_map = {}, filter_map = {})
        {
          q: @tree.query(query_map),
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

    end
  end
end

