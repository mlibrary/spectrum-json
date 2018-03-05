module Spectrum
  module Request
    class Holdings
      attr_reader :id

      def initialize(request)
        @id = request[:id]
      end

      def can_sort?
        false
      end

    end
  end
end
