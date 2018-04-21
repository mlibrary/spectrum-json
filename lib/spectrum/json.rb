require "json-schema"
require 'lru_redux'

require "active_support"
require "active_support/concern"

require 'spectrum/holding'
require 'spectrum/floor_location'
require 'spectrum/bib_record'

require "spectrum/json/version"
require "spectrum/json/engine"
require "spectrum/json/schema"

require 'spectrum/json/ris'
require 'spectrum/json/twilio'
require 'spectrum/json/email'

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
require 'spectrum/response/specialists'
require 'spectrum/response/text'
require 'spectrum/response/email'
require 'spectrum/response/file'
require 'spectrum/response/profile'

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
require 'spectrum/request/text'
require 'spectrum/request/email'
require 'spectrum/request/file'
require 'spectrum/request/profile'

require 'spectrum/policy/get_this'

require 'spectrum/json/railtie' if defined?(Rails)

module Spectrum
  module Json
    class << self
      attr_reader :base_url, :actions, :filter, :fields, :foci, :sorts, :sources, :bookplates

      def configure(root, base_url)
        @base_url     = base_url
        @actions_file = root.join('config', 'actions.yml')
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
        @actions = Spectrum::Config::ActionList.new(YAML.load_file(@actions_file))
        @sources = Spectrum::Config::SourceList.new(YAML.load_file(@sources_file))
        @bookplates = Spectrum::Config::BookplateList.new(YAML.load_file(@bookplates_file))
        @filters = Spectrum::Config::FilterList.new(YAML.load_file(@filters_file))
        @sorts   = Spectrum::Config::SortList.new(YAML.load_file(@sorts_file))
        @fields  = Spectrum::Config::FieldList.new(YAML.load_file(@fields_file), self)
        @foci    = Spectrum::Config::FocusList.new(
          Dir.glob(@focus_files).map {|file| YAML.load_file(file) },
          self
        )

        @actions.configure!

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


      def routes app
        foci.routes(app)

        app.match 'profile',
          to: 'json#profile',
          defaults: { type: 'Profile' },
          via: [:get, :options]

        ['text', 'email', 'file'].each do |action|
          app.match action,
            to: "json##{action}",
            defaults: { type: action.titlecase },
            via: [ :post, :options ]
        end
      end

    end
  end
end
