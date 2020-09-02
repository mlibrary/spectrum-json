module Spectrum
  class Holding
    class BookThisAction < Action
      label 'Book This' 

      def self.match(_, _, _, _, info)
        info['can_book']
      end

      def finalize
        super.merge(href: href)
      end

      private

      def query
        {
          func: 'booking-req-form-itm',
          adm_library: 'MIU50',
          adm_doc_number: adm_doc_number,
          adm_item_sequence: adm_item_sequence,
          exact_item: 'N'
        }.to_query
      end

      def base_url
        Exlibris::Aleph::Config.base_url  || 'http://mirlyn-aleph.lib.umich.edu'
      end

      def href
        base_url + '/F/?' + query
      end

      def adm_doc_number
        info['full_item_key'].slice(0, 9)
      end

      def adm_item_sequence
       info['full_item_key'].slice(9, 6)
      end

    end
  end
end
