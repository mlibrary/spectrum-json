require 'yaml'

module Spectrum
  module Policy
    class GetThis

      class Grant
        attr_reader :attribute, :features
        def initialize(attribute, features)
          @attribute = attribute
          @features = features
        end

        def allow(account, record)
          h = {'patron' => account, 'holding' => record}
          features.all? { |feature| h[@attribute].send(feature) }
        end
      end

      class Option
        attr_reader :label, :service_type, :duration, :description, :tip, :faq, :form,
          :grants, :weight

        def initialize(config)
          @label = config['label']
          @service_type = config['service_type']
          @duration = config['duration']
          @description = config['description']
          @tip = config['tip']
          @faq = config['faq']
          @form = config['form']
          @grants = config['grants'].map do |attribute, features|
            Grant.new(attribute, features)
          end
          @weight = config['weight'] || 0
        end

        def resolve(account, record)
          return nil unless allow?(account, record)
          replace(account, record)
        end

        def allow?(account, record)
          grants.all? {|grant| grant.allow(account, record) }
        end

        def replace(account, record)
          new_hash = Marshal.load(Marshal.dump(to_h))
          if new_hash['form']
            new_hash['form']['action'] = replace_string(new_hash['form']['action'], account, record)
            new_hash['form']['fields'].each do |field|
              field['value'] = replace_string(field['value'], account, record) if field['value']
            end
          end
          new_hash
        end

        def replace_string(input_string, account, record)
          input_string
            .gsub('{$barcode}', record.barcode)
            .gsub('{$record_id}', record.id)
            .gsub('{$patron_id}', account.id)
            .gsub('{$patron_name}', account.name)
            .gsub('{$two_months_from_today}', (DateTime.now >> 2).strftime('%Y-%m-$d'))
        end

        def to_h
          {
            'label' => label,
            'service_type' => service_type,
            'duration' => duration,
            'description' => description,
            'tip' => tip,
            'faq' => faq,
            'form' => form
          }
        end
      end

      class << self

        attr_reader :options

        def load_config(config_file)
          @options = YAML.load_file(config_file).map do |option|
            Option.new(option)
          end
        end

        def options
          @options ||= {}
        end

        def resolve(account, record)
          options.map {|option| option.resolve(account, record) }.compact
        end

      end

      attr_reader :account, :record

      def initialize(account, record)
        @account = account
        @record  = record
      end

      def resolve
        self.class.resolve(account, record)
      end

      private
      def options
        self.class.options
      end

    end
  end
end
