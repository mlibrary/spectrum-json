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
        @names           = Array(@data['names'] || @data['title'])
        @names_have_html = @data['names_have_html'] || false
        @fields          = @focus.apply_fields(@data, @base_url)
      end

      def initialize_from_object
        @url             = @focus.get_url(@data, @base_url)
        @type            = @data.content_types || @source.id
        @complete        = true
        @names           = Array(@data.title)
        @names_have_html = false
        @fields          = @focus.apply_fields(@data, @base_url)
      end


      def spectrum
        {
          type: @type,
          source: @url,
          complete: @complete,
          names: @names,
          names_have_html: @names_have_html,
          fields: @fields,
        }
      end
    end
  end
end
