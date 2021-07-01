module Spectrum
  class Holding
    class RequestThisAction < Action
      def self.label
        'Request This' 
      end

      def self.match?(item)
        ['SPEC','BENT','CLEM'].include?(item.library)
      end

      def finalize
        super.merge(href: href)
      end

      private
      def restriction
        @item.restriction
      end

      def fixedshelf
        @item.inventory_number
      end

      def sublocation
        @item.location
      end

      def location
        return nil if @item.library == 'BENT'
        @item.library
      end

      def description
        (@item.description || '').slice(0, 250)
      end

      def callnumber
        @item.callnumber
      end

      def edition
        (@item.edition || '').slice(0, 250)
      end

      def extent
        (@item.physical_description || '').slice(0, 250)
      end

      def item_date
        (@item.date || '').slice(0, 250)
      end

      def item_publisher
        (@item.pub || '').slice(0, 250)
      end

      def item_place
        (@item.place || '').slice(0, 250)
      end

      def publisher
        (@item.publisher || '').slice(0, 250)
      end

      def date
        @item.pub_date
      end

      def item_author
        (@item.author || '').slice(0, 250)
      end

      def title
        (@item.title || '').slice(0, 250)
      end

      def isbn
        @item.isbn
      end

      def issn
        @item.issn
      end

      def barcode
        @item.barcode
      end

      def genre
        @item.genre
      end

      def sgenre
        @item.sgenre
      end

      def base_url
        case @item.library
        when 'BENT'
          'https://aeon.bentley.umich.edu/login?'
        when 'CLEM'
          'https://chara.clements.umich.edu/aeon/?'
        else
          'https://iris.lib.umich.edu/aeon/?'
        end
      end

      def query
        {
          Action: '10',
          Form: '30',
          genre: genre,
          sgenre: sgenre,
          sysnum: @item.mms_id,
          issn: issn,
          isbn: isbn,
          title: title,
          ItemAuthor: item_author,
          'rft.au': item_author,
          date: date,
          publisher: publisher,
          itemPlace: item_place,
          itemPublisher: item_publisher,
          itemDate: item_date,
          extent: extent,
          'rft.edition': edition,
          callnumber: callnumber,
          description: description,
          location: location,
          sublocation: sublocation,
          barcode: barcode,
          fixedshelf: fixedshelf,
          restriction: restriction,
        }.to_query
      end

      def href
        base_url + query
      end

    end
  end
end
