module Spectrum
  module Response
    class Email
      attr_accessor :request, :driver

      def initialize(request)
        self.request = request
        self.driver  = Spectrum::Json::actions['email'].driver
      end

      def spectrum
        return needs_authentication unless @request.logged_in?
        result = driver.message(request.to, request.from, request.items)
        ret = {}
        ret[:status] = 'Success'
        ret
      end

      private
      def needs_authentication
        { status: "Not logged in", options: [] }
      end

    end
  end
end
