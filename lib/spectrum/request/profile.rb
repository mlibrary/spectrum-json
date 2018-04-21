module Spectrum
  module Request
    class Profile
      attr_reader :request

      def initialize(request)
        @request = request
      end

      def status
        return 'Not logged in' if username.nil? || username.empty?
        'Logged in'
      end

      def sms
        return nil if username.nil? || username.empty?
        Aleph::Borrower.new.tap { |patron| patron.bor_info(username) }.sms
      end

      def username
        request.env['HTTP_X_REMOTE_USER']
      end

      def email
        return nil unless username
        return username if username.include?('@')
        username + '@umich.edu'
      end

      def institutions
        request.env['dlpsInstitutionId']
      end
    end
  end
end
