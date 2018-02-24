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
        end.keys.map do |field|
          RSolr.solr_escape(field).gsub(' ', '\ ')
        end
      end

      def fetch_specialists(terms)
        params = {
          q: "+#{fields.last}:(#{terms.join(' OR ')})",
          rows: 5,
          fl: '*',
          fq: '+source:drupal-users +status:true',
          wt: 'ruby',
        }
        client.last.get('select', params: params)
      end

      def find(query)
        records = fetch_records(query)
        return [] unless records

        terms = extract_terms(records)
        return [] if terms.empty?

        specialists = fetch_specialists(terms)
        return [] unless specialists
        specialists['response']['docs'].map do |specialist|
          extract_fields(specialist)
        end
      end
    end

    class SpecialistDirect < SpecialistEngine
      def find(query)
      end
    end

    class Specialists

      class << self
        attr_reader :config
        def configure(file)
          @config = YAML.load_file(file).map do |key, value|
            [key, ::Spectrum::Response::SpecialistEngine(value)]
          end.to_h
        end
      end

      attr_reader :data

      def initialize(args)
        @data = args
      end

      def engines
        self.class.config.values
      end

      def spectrum
        merge(engines.map { |engine|
          engine.find(data[:request].query(
            data[:focus].fields,
            data[:focus].facet_map
          )[:q])
        })
      end

      def merge(results)
        results.flatten.compact
      end

      def hlb_specialists
        [
          {
            name: 'Scott Dennis',
            url: 'https://www.lib.umich.edu/users/sdenn',
            job_title: 'Librarian for Philosophy, General Reference, and Core Electronic Resources',
            picture: 'https://www.lib.umich.edu/sites/default/files/pictures/picture-205-1471625361.jpg',
            department: 'Arts & Humanities',
            email: 'sdenn@umich.edu',
            phone: '734-647-6484',
            office: [
              '209 Hatcher North',
              'Ann Arbor, MI 48109-1190',
            ]
          }
        ]
      end

      def le_specialists
        [
          {
            name: 'Dave Carter',
            url: 'https://www.lib.umich.edu/users/superman',
            job_title: 'Video Game Archivist & Reference Librarian',
            picture: 'https://www.lib.umich.edu/sites/default/files/pictures/picture-141-1375893456.jpg',
            department: 'Connected Scholarship',
            email: 'superman@umich.edu',
            phone: '734-615-7158',
            office: [
              '2216 LSA',
              'Ann Arbor, MI 48109-0320',
            ]
          }
        ]
      end
    end
  end
end
