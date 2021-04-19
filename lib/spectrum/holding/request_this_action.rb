module Spectrum
  class Holding
    class RequestThisAction < Action
      def self.label
        'Request This' 
      end

      def self.match?(_, _, _, _, info)
        info['can_reserve']
      end

      def finalize
        super.merge(href: href)
      end

      private
      def restriction
        bib.restriction
      end

      def fixedshelf
        info['inventory_number']
      end

      def barcode
        info['barcode']
      end

      def sublocation
        item['collection']
      end

      def location
        return nil if item['sub_library'] && item['sub_library'] == 'BENT'
        item['sub_lobrary']
      end

      def description
        (info['description'] || '').slice(0, 250)
      end

      def callnumber
        info['callnumber'] || item['callnumber']
      end

      def edition
        (bib.edition || '').slice(0, 250)
      end

      def extent
        (bib.physical_description || '').slice(0, 250)
      end

      def item_date
        (bib.date || '').slice(0, 250)
      end

      def item_publisher
        (bib.pub || '').slice(0, 250)
      end

      def item_place
        (bib.place || '').slice(0, 250)
      end

      def publisher
        (bib.publisher || '').slice(0, 250)
      end

      def date
        bib.pub_date
      end

      def item_author
        (bib.author || '').slice(0, 250)
      end

      def title
        (bib.title || '').slice(0, 250)
      end

      def isbn
        bib.isbn
      end

      def issn
        bib.issn
      end

      def barcode
        info['barcode']
      end

      def genre
        bib.genre
      end

      def sgenre
        bib.sgenre
      end

      def base_url
        return 'https://aeon.bentley.umich.edu/login?' if item['sub_library'] == 'BENT'
        return 'https://chara.clements.umich.edu/aeon/?' if item['sub_library'] == 'CLEM'
        'https://iris.lib.umich.edu/aeon/?'
      end

      def query
        {
          Action: '10',
          Form: '30',
          genre: genre,
          sgenre: sgenre,
          sysnum: id,
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
