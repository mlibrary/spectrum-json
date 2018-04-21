# frozen_string_literal: true

module Spectrum
  module Response
    class Profile
      attr_reader :request
      def initialize(request)
        @request = request
      end

      def spectrum
        {
          status: request.status,
          email: request.email,
          text: request.sms,
          institutions: request.institutions
        }
      end
    end
  end
end
