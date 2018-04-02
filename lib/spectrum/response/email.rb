module Spectrum
  module Response
    class Email
      attr_accessor :request, :driver

      def initialize(request)
        self.request = request
        self.driver  = Spectrum::Json::actions['email'].driver
      end

      def spectrum
        result = driver.message(request.to, request.from, request.items)
        ret = {}
        ret[:status] = 'Success'
        ret
      end
    end
  end
end
