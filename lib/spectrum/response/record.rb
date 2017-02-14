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
        @id              = @data['id']
        @type            = @data['type'] || @source.id
        @complete        = @data['complete'] || true
        @names           = Array(@data['names'] || @data['title'])
        @names_have_html = @data['names_have_html'] || false
        @fields          = @focus.apply_fields(@data)
      end

      def initialize_from_object
        @id              = @data.id
        @type            = @data.content_types || @source.id
        @complete        = true
        @names           = Array(@data.title)
        @names_have_html = false
        @fields          = @focus.apply_fields(@data)
      end


      def spectrum
        {
          type: @type,
          source: @base_url + '/' + @source.id + '/record/' + @id,
          complete: @complete,
          names: @names,
          names_have_html: @names_have_html,
          fields: @fields,
        }
      end
    end
  end
end
