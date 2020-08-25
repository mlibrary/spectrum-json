# frozen_string_literal: true

#FIXME
#require 'aleph'

module Spectrum
  module Response
    class GetThis
      def initialize(source:, request:, get_this_policy: Spectrum::Policy::GetThis,
                    available_online_holding: Spectrum::AvailableOnlineHolding,
                    aleph_borrower: Aleph::Borrower.new, aleph_error: Aleph::Error,
                    holding: Spectrum::Holding, bib_record: Spectrum::BibRecord,
                    client: Spectrum::Utility::HttpClient.new, solr: Spectrum::Utility::Solr.new
                    )

        @source = source
        @request = request
        #dependencies
        @get_this_policy = get_this_policy
        @available_online_holding = available_online_holding
        @aleph_borrower = aleph_borrower
        @aleph_error = aleph_error
        @holding = holding
        @bib_record = bib_record
        @client = client

        @solr = solr
        
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
        rescue @aleph_error
          return patron_not_found
        end
        return patron_expired if patron.expired?

        {
          status: 'Success',
          options: @get_this_policy.new(patron, fetch_bib_record, fetch_holdings_record).resolve
        }
      end

      def fetch_holdings_record
        return @available_online_holding.new(@request.id) if @request.barcode == 'available-online'
        uri = @source.holdings + @request.id
        @holding.new( @client.get(uri), @request.id, @request.barcode)
      end

      def fetch_bib_record
        client = @solr.connect(url: @source.url)
        @bib_record.new(client.get('select', params: { q: "id:#{@solr.solr_escape(@request.id)}" }))
      end

      def process_response(response)
        data = []
        response.each do |item|
          next unless item['item_info']
          item['item_info'].each do |info|
            data << process_item_info(item, info)
          end
        end
        data
      end

      def process_item_info(item, info)
        if info['barcode']
          process_mirlyn_item_info(item, info)
        else
          process_hathitrust_item_info(item, info)
        end
      end

      def get_type(info)
        if info['can_request']
          'circulating'
        elsif info['can_reserve']
          'special'
        elsif info['can_book']
          'media'
        else
          'other'
        end
      end

      def get_url(info)
        record = @request.id
        if info['can_request']
          query = { barcode: info['barcode'], getthis: 'Get this' }.to_query
          "https://mirlyn.lib.umich.edu/Record/#{record}/Hold?#{query}"
        elsif info['can_reserve']
          query = { barcode: info['barcode'] }.to_query
          url = "https://mirlyn.lib.umich.edu/Record/#{record}/Request?#{query}"
        elsif info['can_book']
          query = { full_item_key: info['full_item_key'] }.to_query
          url = "https://mirlyn.lib.umich.edu/Record/#{record}/Booking?#{query}"
        end
      end

      def process_mirlyn_item_info(item, info)
        {
          type: get_type(info),
          url: get_url(info),
          barcode: info['barcode'],
          location: info['location'],
          callnumber: info['callnumber'],
          status: info['status'],
          enum: [info['enum_a'], info['enum_b'], info['enum_c']].compact,
          chron: [info['chron_i'], info['chron_j']].compact,
          info_link: item['info_link'],
          description: info['description'],
          summary_holdings: item['summary_holdings']
        }
      end

      def process_hathitrust_item_info(item, info)
        {
          type: 'hathitrust',
          id: info['id'],
          handle_url: "http://hdl.handle.net/2027/#{info['id']}?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth",
          source: info['source'],
          rights: info['rights'],
          status: info['status'],
          description: info['description'],
          summary_holdings: item['summary_holdings']
        }
      end
    end
  end
end
