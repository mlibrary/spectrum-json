# frozen_string_literal: true

module Spectrum
  module Request
    class PlaceHold
      def self.configure
        yield self
      end

      def can_sort?
        false
      end

      class << self
        attr_writer :lib
      end

      class << self
        attr_writer :adm
      end

      class << self
        attr_reader :lib
      end

      class << self
        attr_reader :adm
      end

      attr_reader :request, :patron
      def initialize(request)
        @request = request
        @record_id = get_record_id_from_request(request)
        @source = get_source_from_request(request)
        @item_key = get_item_key_from_request(request)
        user = request.env['HTTP_X_REMOTE_USER']
        begin
          if user && !user.empty?
            # The order matters here because Aleph::Borrower#bor_info raises an exception if the account isn't valid
            @logged_in = true
            @patron = Aleph::Borrower.new.tap { |patron| patron.bor_info(user) }
            @valid_account = true
            @option = Spectrum::Policy::GetThis.new(@patron, fetch_bib_record, fetch_holdings_record).resolve.reject do |service|
              ['Self Service', 'Document Delivery'].include? service['service_type']
            end.first
          end
        rescue StandardError
        end
      end

      def success_message
        return {} unless @option
        {
          label: @option['label'],
          service_type: @option['service_type'],
          duration: @option['duration'],
          description: {
            heading: @option['description']['heading'],
            content: @option['description']['content'].slice(0, @option['description']['content'].length - 1)
          }
        }
      end

      def get_source_from_request(request)
        Spectrum::Json.sources[request.params['source']]
      end

      def get_record_id_from_request(request)
        request.params['record']
      end

      def get_item_key_from_request(request)
        request.params['item']
      end

      def get_barcode_from_holdings_data_with_key(holdings_data, key)
        holdings_data.values.each do |info_list|
          info_list.each do |info|
            next unless info['item_info']
            info['item_info'].each do |item_info|
              return item_info['barcode'] if item_info['full_item_key'] == key
            end
          end
        end
      end

      def fetch_bib_record
        client = @source.driver.constantize.connect(url: @source.url)
        Spectrum::BibRecord.new(client.get('select', params: { q: "id:#{RSolr.solr_escape(@record_id)}" }))
      end

      def fetch_holdings_record
        uri = URI(@source.holdings + @record_id)
        holdings_data = JSON.parse(Net::HTTP.get(uri))
        barcode = get_barcode_from_holdings_data_with_key(holdings_data, @item_key)
        Spectrum::Item.for_barcode(holdings_data, @record_id, barcode)
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
