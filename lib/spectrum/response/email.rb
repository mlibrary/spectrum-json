module Spectrum
  module Response
    class Email
      attr_accessor :request, :driver

      def initialize(request)
        self.request = request
        self.driver  = Spectrum::Json::actions['email'].driver
      end

      def spectrum
        return needs_authentication unless request.logged_in?
        return invalid_email unless request.to.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
        result = driver.message(request.to, request.from, request.items)
        ret = {}
        ret[:status] = 'Success'
        ret
      end

      private

      def invalid_email
        { status: "Invalid email", options: [] }
      end

      def needs_authentication
        { status: "Not logged in", options: [] }
      end

    end
  end
end
