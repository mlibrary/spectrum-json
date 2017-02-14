module Spectrum
  module Response
    class Holdings
      def initialize(args = {})
        @data     = args[:data]
        @focus    = args[:focus]
        @source   = args[:source]
        @base_url = args[:base_url]

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
