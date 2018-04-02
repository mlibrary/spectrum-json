module Spectrum
  module Response
    class Text
      attr_accessor :request, :driver

      def initialize(request)
        self.request = request
        self.driver  = Spectrum::Json::actions['text'].driver
      end

      def spectrum
        return needs_authentication unless request.logged_in?
        result = driver.message(request.to, request.items)
        ret = {}
        if result.all? {|message| message.status == 'accepted'}
          ret[:status] = 'Success'
        elsif result.any? {|message| message.status == 'accepted'}
          ret[:status] = 'Partial success'
        else
          ret[:status] = 'Failed'
        end
        ret[:details] = {
          requested: request.items.length,
          success: result.select {|message| message.status == 'accepted'}.length,
          failure: result.select {|message| message.status != 'accepted'}.length
        }
        ret
      end

      private
      def needs_authentication
        { status: "Not logged in", options: [] }
      end

    end
  end
end
