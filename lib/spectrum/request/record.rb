module Spectrum
  module Request
    class Record

      def initialize(request)
        @request = request
        if request.params[:source] == 'summon'
          @query = "#{@request.params['id_field']}:#{unfiltered_id(request)}"
        else
          @query = "#{@request.params['id_field']}:#{RSolr.solr_escape(unfiltered_id(request))}"
        end
      end

      def can_sort?
        false
      end

      def unfiltered_id(request)
        path = request.path
        original = request.original_fullpath
        id = request.params[:id]
        original.slice(path.length - id.length, original.length)
      end

      def authenticated?
        # TODO: Implement this for production.
        true
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

      def book_mark?
        begin
          @request.params['type'] == 'Record' && @request.params['id_field'] == 'BookMark'
        rescue
          false
        end
      end

      def book_mark
        begin
        @request.params['id']
        rescue
        end
      end

      def holdings_only?
        # TODO: Check this for when we implement this completely.
        begin
          if @data['facets']['holdings_only'].nil?
            true
          else
            Array(@data['facets']['holdings_only']).include?('true')
          end
        rescue
          true
        end
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

      def fvf
        nil
      end

      def rff
        nil
      end

      def rf
        nil
      end

    end
  end
end
