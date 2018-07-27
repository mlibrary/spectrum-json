# frozen_string_literal: true

module Spectrum
  module Response
    def self.SpecialistEngine(config)
      case config['type']
      when 'two-step'
        SpecialistTwoStep
      else
        SpecialistDirect
      end.new(config)
    end

    class EmptyFieldsFieldList
      def by_uid(_uid)
        self
      end

      def query_field
        ''
      end

      def query_params
        {}
      end
    end

    class SpecialistEngine
      attr_reader :config
      def initialize(config)
        @config = config
      end

      def find(_data)
        puts "#{@config.inspect}.find"
      end

      def focus
        @focus ||= Spectrum::Json.foci[config['focus']]
      end

      def source
        @source ||= Spectrum::Json.sources[focus.source]
      end

      def client
        @client ||= source.driver.constantize.connect(url: source.url)
      end

      def fields
        config['fields']
      end

      def rows
        config['rows']
      end

      def term_threshold
        config['term_threshold']
      end

      def extract_fields(specialist)
        {
          name: specialist['title'],
          url: specialist['url'],
          job_title: specialist['job_title'],
          picture: specialist['smfield_picture_url'].first,
          department: specialist['ssfield_user_department'],
          email: specialist['email'].first,
          phone: specialist['ssfield_phone'],
          office: specialist['smfield_user_location'].first.strip.split(/\n/)
        }
      end
    end

    class SpecialistTwoStep < SpecialistEngine
      def focus
        @focus ||= Array(config['focus']).map { |f| Spectrum::Json.foci[f] }
      end

      def source
        @source ||= focus.map { |f| Spectrum::Json.sources[f.source] }
      end

      def client
        @client ||= source.map { |s| s.driver.constantize.connect(url: s.url) }
      end

      def fetch_records(query)
        params = focus.first.solr_params.merge(
          q: query,
          qq: '"' + RSolr.solr_escape(query) + '"',
          rows: rows.first,
          fl: fields.first
        )
        client.first.get('select', params: params)
      end

      def extract_terms(records)
        records['response']['docs'].map do |doc|
          doc[fields.first]
        end.compact.flatten.each_with_object(Hash.new(0)) do |field, list|
          list[field] += 1
        end.delete_if do |_field, count|
          count < term_threshold
        end.map do |field, count|
          [RSolr.solr_escape(field).gsub(' ', '\ '), count]
        end.to_h
      end

      def fetch_specialists(terms)
        bq = []
        terms.each_pair do |term, count|
          bq << "#{fields.last}:(#{term})^#{count}"
        end

        params = {
          mm: 1,
          q: terms.keys.join(' OR '),
          qf: fields.last,
          pf: fields.last,
          bq: bq,
          defType: 'edismax',
          rows: 10,
          fl: '*',
          fq: '+source:drupal-users +status:true',
          wt: 'ruby'
        }
        client.last.get('select', params: params)
      end

      def empty_results
        {
          config['keys']['terms'] => {},
          config['keys']['specialists'] => []
        }
      end

      def find(query)
        records = fetch_records(query[:q])
        return empty_results unless records

        terms = extract_terms(records)
        return empty_results if terms.empty?

        specialists = fetch_specialists(terms)
        return empty_results unless specialists

        specialists = specialists['response']['docs'].map do |specialist|
          extract_fields(specialist)
        end
        {
          config['keys']['terms'] => terms,
          config['keys']['specialists'] => specialists
        }
      end
    end

    class SpecialistDirect < SpecialistEngine
      def fetch_specialists(query)
        params = {
          mm: 1,
          q: query,
          qf: fields,
          pf: fields,
          bq: bq,
          defType: 'edismax',
          rows: 10,
          fl: 'score,*',
          fq: '+source:drupal-users +status:true',
          wt: 'ruby'
        }
        client.last.get('select', params: params)
      end

      def find(_query)
        {
          config['keys']['terms'] => {},
          config['keys']['specialists'] => []
        }
      end
    end

    class Specialists
      class << self
        attr_reader :config, :logger, :cache
        def configure(file)
          @config = YAML.load_file(file).map do |key, value|
            if key == 'logger'
              @logger = value
              nil
            elsif key == 'cache'
              @cache = value['driver'].constantize.new(value['size'], value['ttl'])
              nil
            else
              [key, ::Spectrum::Response::SpecialistEngine(value)]
            end
          end.compact.to_h
          @cache ||= LruRedux::TTL::ThreadSafe.new(500, 43_200)
        end
      end

      attr_reader :data

      def initialize(args)
        @data = args
      end

      def cache
        self.class.cache
      end

      def logger
        self.class.logger
      end

      def engines
        self.class.config.values
      end

      def spectrum
        return [] if data[:request].instance_eval { @request&.env&.fetch('dlpsInstitutionId')&.include?('Flint') }
        query = data[:request].query(
          EmptyFieldsFieldList.new,
          data[:focus].facet_map
        )
        cache.getset(query) do
          begin
            results = engines.map do |engine|
              engine.find(query)
            end.inject({}) do |acc, item|
              acc.merge(item)
            end
            report(
              query: query[:q],
              filters: query[:fq],
              hlb: results['hlb'].keys.map { |term| term.delete('\\') },
              expertise: results['expertise'].keys,
              hlb_expert: results['hlb_expert'].map { |expert| expert[:email].sub(/@umich.edu/, '') },
              expertise_expert: results['expertise_expert']
            )
            merge(results['hlb_expert'] + results['expertise_expert'])
          rescue
            []
          end
        end
      end

      def merge(results)
        results.flatten.compact
      end

      def report(user: '', query: '', filters: [], hlb: [], expertise: [], hlb_expert: [], expertise_expert: [])
        return unless logger
        Thread.new do
          uri = URI(logger)
          req = Net::HTTP::Post.new(uri)
          req.body = {
            user: user,
            query: query,
            filters: filters,
            hlb: hlb,
            expertise: expertise,
            hlb_expert: hlb_expert,
            expertise_expert: expertise_expert
          }.to_query
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            http.request(req)
          end
        end
      end
    end
  end
end
