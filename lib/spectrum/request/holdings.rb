# frozen_string_literal: true

module Spectrum
  module Request
    class Holdings
      attr_reader :id, :focus

      def initialize(request)
        @id = request[:id]
        @focus = request[:id]
      end

      def can_sort?
        false
      end
    end
  end
end
