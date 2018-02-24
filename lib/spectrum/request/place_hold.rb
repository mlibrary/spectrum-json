module Spectrum
  module Request
    class PlaceHold
      def self.configure
        yield self
      end

      def self.lib=(value)
        @lib = value
      end

      def self.adm=(value)
        @adm = value
      end

      def self.lib
        @lib
      end

      def self.adm
        @adm
      end

      attr_reader :request, :patron
      def initialize(request)
        @request = request
        user = request.env['HTTP_X_REMOTE_USER']
        begin
          if user && !user.empty?
            # The order matters here because Aleph::Borrower#bor_info raises an exception if the account isn't valid
            @logged_in = true
            @patron = Aleph::Borrower.new.tap {|patron| patron.bor_info(user) }
            @valid_account = true
          end
        rescue
        end
      end

      def logged_in?
        @logged_in
      end

      def valid_account?
        @valid_account
      end

      def lib
        self.class.lib
      end

      def adm
        self.class.adm
      end

      def patron_id
        patron.id
      end

      def record_id
        lib + request.params[:record]
      end

      def item_id
        adm + request.params[:item]
      end

      def pickup_location
        Exlibris::Aleph::PickupLocation.new(
          request.params[:pickup_location],
          request.params[:pickup_location]
        )
      end

      def not_needed_after
        request.params[:not_needed_after]
      end
    end
  end
end
