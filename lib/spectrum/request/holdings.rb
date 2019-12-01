# frozen_string_literal: true

module Spectrum
  module Request
    class Holdings
      attr_reader :id, :focus

      def initialize(request)
        @id = request[:id]
        @htso = request[:htso]
        @focus = request[:focus]
      end

      def htso?
        @htso
      end

      def can_sort?
        false
      end
    end
  end
end
