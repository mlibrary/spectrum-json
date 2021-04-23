# frozen_string_literal: true

require 'aleph'

module Spectrum
  module Response
    class GetThis
      def initialize(source:, request:, 
                     get_this_policy_factory: lambda {|patron, bib_record, holdings_record| Spectrum::Policy::GetThis.new(patron, bib_record, holdings_record)}, aleph_borrower: Aleph::Borrower.new,
                     bib_record: Spectrum::BibRecord.fetch(id: request.id, url: source.url),
                     holding_picker: lambda{|request, source| Spectrum::Entities::Item.for_get_this(request: request, source: source)}
                    )
        @source = source
        @request = request

        @get_this_policy_factory = get_this_policy_factory
        @holding_picker = holding_picker

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

        {
          status: 'Success',
          options: @get_this_policy_factory.call(patron, @bib_record, @holding_picker.call(@request, @source)).resolve
        }
      end

    end
  end
end
