module Spectrum
  class ItemAction
    def initialize(item: item)
      @item = item
    end
    def self.for(item:, source:, bib_fetcher: Spectrum::Utility::BibFetcher.new)
      if item.can_request?
        RequestItemAction.new(item: item)
      elsif item.can_reserve?
        ReserveItemAction.new(item: item, 
                              bib: bib_fetcher.fetch(id: item.record, url: source.url))
      elsif item.can_book?
        BookItemAction.new(item:item)
      else
        self.new(item: item)
      end
    end
    def to_h
      { text: 'N/A' }
    end
  end
  class RequestItemAction < ItemAction
    def to_h
      {
        text: 'Get this',
        to: {
          barcode: @item.barcode,
          action: 'get-this',
          record: @item.record,
          datastore: @item.record
        }
      }
    end
  end
  class BookItemAction < ItemAction
    def to_h
      {
        text: "Book this",
        href: '', #FIXME
      }
    end
  end
  class ReserveItemAction < ItemAction
    def initialize(item:, bib:)
      @item = item 
      @bib = bib
    end
    def to_h
      {
        text: 'Request this',
        href: base_url + query_fields.to_query
      }
    end
    def query_fields
      {
        Action: '10',
        Form: '30',
        genre: @bib.genre,
        sgenre: @bib.sgenre,
        sysnum: @item.record,
        issn: @bib.issn,
        isbn: @bib.isbn,
        title: format(@bib.title),
        ItemAuthor: format(@bib.author),
        'rft.au': format(@bib.author),
        date: @bib.pub_date,
        publisher: format(@bib.publisher),
        itemPlace: format(@bib.place),
        itemPublisher: format(@bib.pub),
        itemDate: format(@bib.pub_date),
        extent: format(@bib.physical_description),
        'rft.edition': format(@bib.edition),
        callnumber: @item.call_number,
        description: format(@item.description),
        location: location,
        sublocation: @item.collection,
        barcode: @item.barcode,
        fixedshelf: @item.inventory_number,
        restriction: @bib.restriction,
      }
    end
    private
    def location
      if @item.library == 'BENT'
        nil
      else
        @item.library
      end
    end
    def format(field)
      (field || '').slice(0,250)
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
  end
end
