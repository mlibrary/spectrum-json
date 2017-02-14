module Spectrum
  module Response
    class DataStoreList

      def initialize(args = {})
        list = args[:data] || []
        base_url = args[:base_url] || 'http://localhost'
        @list = list.values.map {|item| DataStore.new({ data: item, base_url: base_url}) }
      end

      def total_available
        @list.length
      end

      def spectrum
        @list.map(&:spectrum)
      end
    end
  end
end

