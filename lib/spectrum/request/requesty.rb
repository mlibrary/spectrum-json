# frozen_string_literal: true

module Spectrum
  module Request
    module Requesty
      extend ActiveSupport::Concern

      FLINT = 'Flint'
      FLINT_PROXY_PREFIX = 'http://libproxy.umflint.edu:2048/login?url='
      DEFAULT_PROXY_PREFIX = 'https://proxy.lib.umich.edu/login?url='
      INSTITUTION_KEY = 'dlpsInstituionId'

      included do
        attr_accessor :request_id, :slice, :sort
      end

      def can_sort?
        true
      end

      def proxy_prefix
        return FLINT_PROXY_PREFIX if @request.env[INSTITUTION_KEY]&.include?(FLINT)
        DEFAULT_PROXY_PREFIX
      end

      def initialize(request = nil, focus = nil)
        @request = request
        @focus   = focus
        if @request&.post?
          @raw = @request.raw_post
          @data = JSON.parse(@raw)

          bad_request 'Request json did not validate' unless Spectrum::Json::Schema.validate(:request, @data)

          if @data
            @uid        = @data['uid']
            @start      = @data['start'].to_i
            @count      = @data['count'].to_i
            @page       = @data['page']
            @tree       = Spectrum::FieldTree.new(@data['field_tree'])
            @facets     = Spectrum::FacetList.new(@focus.default_facets.merge(@focus.filter_facets(@data['facets'] || {})))
            @sort       = @data['sort']
            @settings   = @data['settings']
            @request_id = @data['request_id']

            if @page || @count == 0
              @page_size = @count
            elsif @start < @count
              @slice = [@start, @count]
              @page_size = @start + @count
              @page_number = 0
            else
              last_record = @start + @count
              @page_size = @count
              @page_number = (@start / @page_size).floor

              while @page_number > 0 && @page_size * (@page_number + 1) < last_record
                first_record = @page_size * @page_number
                if @start - first_record < @page_number
                  @page_size = (last_record / @page_number).ceil
                else
                  @page_size += (@start - first_record).floor
                end
                @page_number = (@start / @page_size).floor
              end
              @slice = [@start - @page_size * @page_number, @count]
            end

            validate!
          end
        end
        @page = (@page_number || 0) + 1

        @start     ||= 0
        @count     ||= 0
        @slice     ||= [0, @count]
        @tree      ||= Spectrum::FieldTree::Empty.new
        @facets    ||= Spectrum::FacetList.new(nil)
        @page_size ||= 0
      end

      def pseudo_facet?(name, default = false)
        return default if @data.nil? || @data['facets'].nil? || @data['facets'][name].nil?
        Array(@data['facets'][name]).include?('true')
      end

      # TODO: Find a way to make this configurable
      def available_online?
        pseudo_facet?('available_online')
      end

      def search_only?
        @focus && @focus.id == 'mirlyn' && pseudo_facet?('search_only', true)
      end

      def holdings_only?
        pseudo_facet?('holdings_only', true)
      end

      def exclude_newspapers?
        pseudo_facet?('exclude_newspapers')
      end

      def is_scholarly?
        pseudo_facet?('is_scholarly')
      end

      def book_mark?
        @request.params['type'] == 'Record' && @request.params['id_field'] == 'BookMark'
      rescue StandardError
        false
      end

      def book_mark
        @request.params['id']
      end

      def authenticated?
        # When @request is nil, the server is making the request for it's own information.
        return true unless @request&.env

        # If there's a @request.env, but not a dlpsInstitutionId then it's empty.
        return false unless @request.env['dlpsInstitutionId']

        # If we found an institution we're authenticated.
        @request.env['dlpsInstitutionId'].length > 0
      end

      # For summon's range filter (i.e. an applied filter)
      def rf
        @focus ? @focus.rf(@facets) : []
      end

      # For summon's range filter facet (i.e. a filter to ask for counts of)
      def rff
        @focus ? @focus.rff(@facets) : []
      end

      def fvf(_filter_map = {})
        @focus ? @focus.fvf(@facets) : []
      end

      def query(query_map = {}, filter_map = {})
        {
          q: @tree.query(query_map),
          page: @page,
          start: @start,
          rows: @page_size,
          fq: @facets.query(filter_map, (@focus&.value_map) || {}),
          per_page: @page_size
        }.merge(@tree.params(query_map))
      end

      def facets
        @facets
      end

      def spectrum
        ret = {
          uid: @uid,
          start: @start,
          count: @count,
          field_tree: @tree.spectrum,
          facets: @facets.spectrum,
          sort: @sort,
          settings: @settings
        }
        if @request_id
          ret.merge(request_id: @request_id)
        else
          ret
        end
      end

      private

      def bad_request(message)
        raise ActionController::BadRequest.new('input', Exception.new(message))
      end

      def validate!
        bad_request 'uid is required' if @uid.nil?
        bad_request 'start must be >= 0' if @start < 0
        bad_request 'count must be >= 0' if @count < 0
        bad_request @tree.error unless @tree.valid?
        # TODO:
        # raise ActionController::BadRequest.new("input", @facets) unless @facets.valid?
        # bad_request "No sort specified" if @sort.nil?
      end
    end
  end
end
