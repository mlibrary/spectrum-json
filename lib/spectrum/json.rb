require "json-schema"

require "active_support"
require "active_support/concern"

require 'spectrum/holding'
require 'spectrum/floor_location'
require 'spectrum/bib_record'

require "spectrum/json/version"
require "spectrum/json/engine"
require "spectrum/json/schema"

require "spectrum/response"
require "spectrum/response/spectrumable"
require "spectrum/response/message"
require "spectrum/response/data_store"
require "spectrum/response/data_store_list"
require "spectrum/response/facet_list"
require "spectrum/response/record"
require "spectrum/response/record_list"
require 'spectrum/response/holdings'
require 'spectrum/response/get_this'
require 'spectrum/response/place_hold'

require "spectrum/field_tree"
require "spectrum/field_tree/base"
require "spectrum/field_tree/field"
require "spectrum/field_tree/field_boolean"
require "spectrum/field_tree/literal"
require "spectrum/field_tree/empty"
require "spectrum/field_tree/invalid"

require "spectrum/facet_list"

require "spectrum/request"
require "spectrum/request/record"
require "spectrum/request/requesty"
require "spectrum/request/null"
require "spectrum/request/facet"
require "spectrum/request/data_store"
require 'spectrum/request/holdings'
require 'spectrum/request/get_this'
require 'spectrum/request/place_hold'

require 'spectrum/policy/get_this'

require 'spectrum/json/railtie' if defined?(Rails)

module Spectrum
  module Json
    class << self

      def configure(root)
        @filters_file = root.join('config', 'filters.yml')
        @fields_file  = root.join('config', 'fields.yml')
        @focus_files  = root.join('config', 'foci', '*.yml')
        @sources_file = root.join('config', 'source.yml')
        @sorts_file   = root.join('config', 'sorts.yml')
        @bookplates_file = root.join('config', 'bookplates.yml')
        Spectrum::Config::FacetParents.configure(root)
        configure!
      end

      def configure!
        @sources = Spectrum::Config::SourceList.new(YAML.load_file(@sources_file))
        @bookplates = Spectrum::Config::BookplateList.new(YAML.load_file(@bookplates_file))
        @filters = Spectrum::Config::FilterList.new(YAML.load_file(@filters_file))
        @sorts   = Spectrum::Config::SortList.new(YAML.load_file(@sorts_file))
        @fields  = Spectrum::Config::FieldList.new(YAML.load_file(@fields_file), self)
        @foci    = Spectrum::Config::FocusList.new(
          Dir.glob(@focus_files).map {|file| YAML.load_file(file) },
          self
        )

        request  = Spectrum::Request::DataStore.new

        @foci.values.each do |focus|
          focus.get_null_facets do
            source = @sources[focus.source]
            engine = source.engine(focus, request, nil)
            begin
              results = engine.search
              focus.apply_facets!(results)
            rescue Exception => e
            end
          end
        end

        self
      end

      def filters
        @filters
      end

      def fields
        @fields
      end

      def foci
        @foci
      end

      def routes app
        foci.routes(app)
      end

      def sorts
        @sorts
      end

      def sources
        @sources
      end

      def bookplates
        @bookplates
      end
    end
  end
end
