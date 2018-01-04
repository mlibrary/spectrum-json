module Spectrum
  module Request
    class GetThis
      attr_reader :id, :username, :barcode

      def initialize(request)
        @id = request[:id]
        @barcode = request[:barcode]
        @username = request.env['HTTP_X_REMOTE_USER']
      end

    end
  end
end
