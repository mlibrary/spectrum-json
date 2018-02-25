module Spectrum
  module Response
    class PlaceHold
      attr_reader :hold
      def initialize(request)
        @valid_account = request.valid_account?
        @logged_in = request.logged_in?
        @success_message = request.success_message
        @failure_message = {}
        return unless @valid_account
        @hold = Exlibris::Aleph::Patron::Record::Item::CreateHold.new(
          request.patron_id,
          request.record_id,
          request.item_id,
          {
            pickup_location: request.pickup_location,
            last_interest_date: request.not_needed_after,
            start_interest_date: '',
            sub_author: '',
            sub_title: '',
            pages: '',
            note_1: '',
            note_2: '',
            rush: '',
          }
        )
      end

      def renderable
        return { status: 'Not logged in' } unless @logged_in
        return { status: 'No account' } unless @valid_account
        begin
          hold.error?
          {
            status: hold.note,
            orientation: hold.note == 'Action Succeeded' ? @success_message : @failure_message,
          }
        rescue NoMethodError => e
          # Some hold placing errors raise NoMethodErrors,
          # but still have more information available.
          { status: hold.instance_eval { @root }["reply_text"] }
        rescue Exception => e
          # Some other exception
          { status: "Unable to place hold" }
        end
      end
    end
  end
end
