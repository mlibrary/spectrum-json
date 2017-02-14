module Spectrum
  module Response
    class Message
      TYPES = [ :error, :warning, :success, :info ]
      DEFAULT_TYPE = 'info'
      def initialize args = {}
        @class = TYPES.include?(args[:class]) ? args[:class] : DEFAULT_TYPE
        @summary = args[:summary]
        @details = args[:details]
      end

      class << self
        TYPES.each do |type|
          define_method(type) do |args = {}|
            new({:class => type}.merge(args))
          end
        end
        alias_method :warn, :warning
      end

      def spectrum
        { :class => @class, summary: @summary, details: @details }
      end
    end
  end
end
