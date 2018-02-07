module Spectrum
  module Response
    class PlaceHold
      attr_reader :hold
      def initialize(request)
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
        ) if request.patron
      end

      def renderable
        begin
          if hold.nil?
            { status: 'Not logged in' }
          else
            hold.error?
            { status: hold.note }
          end
        rescue
          { status: "Unable to place hold" }
        end
      end
    end
  end
end
