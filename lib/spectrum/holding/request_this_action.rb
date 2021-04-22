module Spectrum
  class Holding
    class RequestThisAction < Action
      def self.label
        'Request This' 
      end

      def self.match?(item)
        item.can_request? 
      end

      def finalize
        super.merge(href: href)
      end

      private
      def restriction
        @bib_record.restriction
      end

      def fixedshelf
        @item.inventory_number
      end

      def barcode
        @item.barcode
      end

      def sublocation
        @item.collection
      end

      def location
        return nil if @item.sub_library == 'BENT'
        @item.sub_library
      end

      def description
        (@item.description || '').slice(0, 250)
      end

      def callnumber
        @item.callnumber
      end

      def edition
        (@bib_record.edition || '').slice(0, 250)
      end

      def extent
        (@bib_record.physical_description || '').slice(0, 250)
      end

      def item_date
        (@bib_record.date || '').slice(0, 250)
      end

      def item_publisher
        (@bib_record.pub || '').slice(0, 250)
      end

      def item_place
        (@bib_record.place || '').slice(0, 250)
      end

      def publisher
        (@bib_record.publisher || '').slice(0, 250)
      end

      def date
        @bib_record.pub_date
      end

      def item_author
        (@bib_record.author || '').slice(0, 250)
      end

      def title
        (@bib_record.title || '').slice(0, 250)
      end

      def isbn
        @bib_record.isbn
      end

      def issn
        @bib_record.issn
      end

      def barcode
        @item.barcode
      end

      def genre
        @bib_record.genre
      end

      def sgenre
        @bib_record.sgenre
      end

      def base_url
        return 'https://aeon.bentley.umich.edu/login?' if @item.sub_library == 'BENT'
        return 'https://chara.clements.umich.edu/aeon/?' if @item.sub_library == 'CLEM'
        'https://iris.lib.umich.edu/aeon/?'
      end

      def query
        {
          Action: '10',
          Form: '30',
          genre: genre,
          sgenre: sgenre,
          sysnum: @item.doc_id,
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
