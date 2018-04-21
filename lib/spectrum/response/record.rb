# frozen_string_literal: true

module Spectrum
  module Response
    class Record
      def initialize(args = {})
        @data     = args[:data]
        @focus    = args[:focus]
        @source   = args[:source]
        @base_url = args[:base_url]

        if @data.respond_to? :[]
          initialize_from_hash
        else
          initialize_from_object
        end
      end

      def initialize_from_hash
        @url             = @focus.get_url(@data, @base_url)
        @type            = @data['type'] || @source.id
        @complete        = @data['complete'] || true
        @fields          = @focus.apply_fields(@data, @base_url)
        @names           = @focus.names(@fields)
        @uid             = @fields.find { |f| f[:uid] == 'id' }[:value]
        @names_have_html = @data['names_have_html'] || true
      end

      def initialize_from_object
        @url             = @focus.get_url(@data, @base_url)
        @type            = @data.content_types || @source.id
        @fields          = @focus.apply_fields(@data, @base_url)
        @names           = @focus.names(@fields)
        @uid             = @fields.find { |f| f[:uid] == 'id' }[:value]
        @complete        = true
        @names_have_html = true
      end

      def spectrum
        {
          type: @type,
          source: @url,
          complete: @complete,
          names: @names,
          uid: @uid,
          datastore: @focus.id,
          names_have_html: @names_have_html,
          has_holdings: @focus.has_holdings?,
          fields: @fields
        }
      end
    end
  end
end
