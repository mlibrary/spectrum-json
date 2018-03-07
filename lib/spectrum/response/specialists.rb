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
      def by_uid(uid)
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

      def find(data)
        puts "#{@config.inspect}.find"
      end

      def focus
        @focus ||= Spectrum::Json::foci[config['focus']]
      end

      def source
        @source ||= Spectrum::Json::sources[focus.source]
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
          office: specialist['smfield_user_location'].first.strip.split(/\n/),
        }
      end
    end

    class SpecialistTwoStep < SpecialistEngine
      def focus
        @focus ||= Array(config['focus']).map {|f| Spectrum::Json::foci[f]}
      end

      def source
        @source ||= focus.map {|f| Spectrum::Json::sources[f.source]}
      end

      def client
        @client ||= source.map {|s| s.driver.constantize.connect(url: s.url) }
      end

      def fetch_records(query)
        params = focus.first.solr_params.merge(
          q: query,
          rows: rows.first,
          fl: fields.first
        )
        client.first.get('select', params: params)
      end

      def extract_terms(records)
        records['response']['docs'].map do |doc|
          doc[fields.first]
        end.compact.flatten.inject(Hash.new(0)) do |list, field|
          list[field] += 1
          list
        end.delete_if do |field, count|
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
          wt: 'ruby',
        }
        client.last.get('select', params: params)
      end

      def find(query)
        records = fetch_records(query[:q])
        return [] unless records

        terms = extract_terms(records)
        return [] if terms.empty?

        specialists = fetch_specialists(terms)
        return [] unless specialists

        specialists = specialists['response']['docs'].map do |specialist|
          extract_fields(specialist)
        end
        {
          config['keys']['terms'] => terms,
          config['keys']['specialists'] => specialists,
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
          wt: 'ruby',
        }
        client.last.get('select', params: params)
      end

      def find(query)
        {
          config['keys']['terms'] => [],
          config['keys']['specialists'] => [],
        }
      end
    end

    class Specialists

      class << self
        attr_reader :config, :logger
        def configure(file)
          @config = YAML.load_file(file).map do |key, value|
            if key == 'logger'
              @logger = value
              nil
            else
              [key, ::Spectrum::Response::SpecialistEngine(value)]
            end
          end.compact.to_h
        end
      end

      attr_reader :data

      def initialize(args)
        @data = args
      end

      def logger
        self.class.logger
      end

      def engines
        self.class.config.values
      end

      def spectrum
        query = data[:request].query(
          EmptyFieldsFieldList.new,
          data[:focus].facet_map
        )
        results = engines.map do |engine|
          engine.find(query)
        end.inject({}) do |acc, item|
          acc.merge(item)
        end
        report(
          query: query[:q],
          filters: query[:fq],
          hlb: results['hlb'],
          expertise: results['expertise'],
          hlb_expert: results['hlb_expert'],
          expertise_expert: results['expertise_expert']
        )
        merge(results['hlb_expert'] + results['expertise_expert'])
      end

      def merge(results)
        results.flatten.compact
      end

      def report(user: '', query: '', filters: '', hlb: [], expertise: [], hlb_expert: [], expertise_expert: [])
        return unless logger
        uri = URI(logger)
        Net::HTTP.post_form(
          uri,
          user: user,
          query: query,
          filters: filters,
          hlb: hlb,
          expertise: expertise,
          hlb_expert: hlb_expert,
          expertise_expert: expertise_expert
        )
      end

    end
  end
end
