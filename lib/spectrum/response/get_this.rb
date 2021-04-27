# frozen_string_literal: true

require 'aleph'
#refactor to use item decorator
module Spectrum
  module Response
    class GetThis
      def initialize(source:, request:, 
                     get_this_policy_factory: lambda {|patron, bib_record, holdings_record| Spectrum::Policy::GetThis.new(patron, bib_record, holdings_record)}, 
                     aleph_borrower: Aleph::Borrower.new,
                     bib_record: Spectrum::BibRecord.fetch(id: request.id, url: source.url),
                     item_picker: lambda{|request, source| Spectrum::Decorators::MirlynItemDecorator.for(request, source)}
                    )
        @source = source
        @request = request

        @get_this_policy_factory = get_this_policy_factory
        @item_picker = item_picker

        @aleph_borrower = aleph_borrower
        @bib_record = bib_record

        @data = fetch_get_this
      end

      def renderable
        @data
      end

      private

      def needs_authentication
        { status: 'Not logged in', options: [] }
      end

      def patron_not_found
        { status: 'Patron not found', options: [] }
      end

      def patron_expired
        { status: 'Patron expired', options: [] }
      end

      def fetch_get_this
        return {} unless @source.holdings
        return needs_authentication unless @request.logged_in?
        begin
          patron = @aleph_borrower.tap { |patron| patron.bor_info(@request.username) }
        rescue Aleph::Error
          return patron_not_found
        end
        return patron_expired if patron.expired?
        item = @item_picker.call(@source, @request)

        {
          status: 'Success',
          options: @get_this_policy_factory.call(patron, @bib_record, item).resolve
        }
      end

    end
  end
end
