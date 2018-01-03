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
        attr_reader :label, :description, :faq, :grants
        def initialize(config)
          @label = config['label']
          @description = config['description']
          @faq = config['faq']
          @grants = config['grants'].map do |attribute, features|
            Grant.new(attribute, features)
          end
        end

        def allow(account, record)
          grants.all? {|grant| grant.allow(account, record) }
        end

        def to_h
          {
            'label' => @label,
            'description' => @description,
            'faq' => @faq
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
          options.select {|option| option.allow(account, record) }.map(&:to_h)
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
