# frozen_string_literal: true

module Spectrum
  module Response
    class RecordList
      attr_accessor :total_available

      def initialize(args = {}, request)
        list     = args[:data] || []
        focus    = args[:focus]
        source   = args[:source]
        base_url = args[:base_url] || 'http://localhost'
        @request = request
        @total_available =  args[:total_available] || list.length
        @list = list.map do |item|
          Record.new(
            {
              data: item,
              source: source,
              focus: focus,
              base_url: base_url
            },
            @request
          )
        end
      end

      def spectrum
        @list.map(&:spectrum)
      end
    end
  end
end
