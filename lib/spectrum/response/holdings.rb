# frozen_string_literal: true

module Spectrum
  module Response
    class Holdings
      def initialize(source, request)
        @source = source
        @request = request
        @data = fetch_holdings
      end

      def renderable
        @data
      end

      private

      def fetch_holdings
        return [] unless @source.holdings
        uri = URI(@source.holdings + @request.id)
        response = JSON.parse(Net::HTTP.get(uri))[@request.id]
        process_response(response)
      end

      def process_response(response)
        data = []
        sorter = Hash.new { |hash, key| hash[key] = key }.tap do |hash|
          hash[nil] = 'AAAA'
          hash['- Offsite Shelving -'] = 'zzzz'
        end
        response.each do |item|
          if item['down_links']
            item['down_links'].each do |link|
              data << process_down_link(link)
            end
          elsif item['up_links']
            item['up_links'].each do |link|
              data << process_up_link(link)
            end
          elsif item['item_info']
            item['item_info'].each do |info|
              data << process_item_info(item, info)
            end
          end
        end
        data.sort_by { |item| sorter[item[:location]] }
      end

      def process_up_link(link)
        {
          type: 'uplink',
          description: 'Included in',
          label: link['link_text'],
          id: link['key']
        }
      end

      def process_down_link(link)
        {
          type: 'downlink',
          description: 'Linked titles',
          label: link['link_text'],
          id: link['key']
        }
      end

      def process_item_info(item, info)
        if info['barcode']
          process_mirlyn_item_info(item, info)
        else
          process_hathitrust_item_info(item, info)
        end
      end

      def get_type(info)
        if info['can_request']
          'circulating'
        elsif info['can_reserve']
          'special'
        elsif info['can_book']
          'media'
        else
          'other'
        end
      end

      def get_url(item, info)
        if info['can_reserve']
          request_this_url(item, info)
        elsif info['can_book']
          advance_booking_url(info)
        end
      end

      def fetch_bib_record
        client = @source.driver.constantize.connect(url: @source.url)
        Spectrum::BibRecord.new(client.get('select', params: { q: "id:#{RSolr.solr_escape(@request.id)}" }))
      end

      def request_this_url(item, info)
        record_id = @request.id
        record = fetch_bib_record

        query = {
          Action: '10',
          Form: '30',
          genre: get_aeon_genre(record, item, info),
          sgenre: get_aeon_sgenre(record, item, info),
          sysnum: record_id,
          issn: get_aeon_issn(record, item, info),
          isbn: get_aeon_isbn(record, item, info),
          title: get_aeon_title(record, item, info),
          ItemAuthor: get_aeon_item_author(record, item, info),
          'rft.au': get_aeon_item_author(record, item, info),
          date: get_aeon_date(record, item, info),
          publisher: get_aeon_publisher(record, item, info),
          itemPlace: get_aeon_item_place(record, item, info),
          itemPublisher: get_aeon_item_publisher(record, item, info),
          itemDate: get_aeon_item_date(record, item, info),
          extent: get_aeon_extent(record, item, info),
          'rft.edition': get_aeon_edition(record, item, info),
          callnumber: get_aeon_callnumber(record, item, info),
          description: get_aeon_description(record, item, info),
          location: get_aeon_location(record, item, info),
          sublocation: get_aeon_sublocation(record, item, info),
          barcode: get_aeon_barcode(record, item, info),
          fixedshelf: get_aeon_fixedshelf(record, item, info)
        }.to_query
        get_aeon_base_url(record, item, info) + query
      end

      def get_aeon_fixedshelf(_record, item, _info)
        item['inventory_number']
      end

      def get_aeon_barcode(_record, _item, info)
        info['barcode']
      end

      def get_aeon_sublocation(_record, item, _info)
        item['collection']
      end

      def get_aeon_location(_record, item, _info)
        return nil if item['sub_library'] && item['sub_library'] == 'BENT'
        item['sub_lobrary']
      end

      def get_aeon_description(_record, item, _info)
        (item['description'] || '').slice(0, 250)
      end

      def get_aeon_callnumber(_record, item, _info)
        item['callnumber']
      end

      def get_aeon_edition(record, _item, _info)
        (record.edition || '').slice(0, 250)
      end

      def get_aeon_extent(record, _item, _info)
        (record.physical_description || '').slice(0, 250)
      end

      def get_aeon_item_date(record, _item, _info)
        (record.date || '').slice(0, 250)
      end

      def get_aeon_item_publisher(record, _item, _info)
        (record.pub || '').slice(0, 250)
      end

      def get_aeon_item_place(record, _item, _info)
        (record.place || '').slice(0, 250)
      end

      def get_aeon_publisher(record, _item, _info)
        (record.publisher || '').slice(0, 250)
      end

      def get_aeon_date(record, _item, _info)
        record.pub_date
      end

      def get_aeon_item_author(record, _item, _info)
        (record.author || '').slice(0, 250)
      end

      def get_aeon_title(record, _item, _info)
        (record.title || '').slice(0, 250)
      end

      def get_aeon_isbn(record, _item, _info)
        record.isbn
      end

      def get_aeon_issn(record, _item, _info)
        record.issn
      end

      def get_aeon_barcode(_record, _item, info)
        info['barcode']
      end

      def get_aeon_genre(record, _item, _info)
        record.genre
      end

      def get_aeon_sgenre(record, _item, _info)
        record.sgenre
      end

      def get_aeon_base_url(_record, item, _info)
        return 'https://agathe.bentley.umich.edu/aeon/?' if item['sub_library'] == 'BENT'
        return 'https://chara.clements.umich.edu/aeon/?' if item['sub_library'] == 'CLEM'
        'https://iris.lib.umich.edu/aeon/?'
      end

      def advance_booking_url(info)
        adm_doc_number = info['full_item_key'].slice(0, 9)
        adm_item_sequence = info['full_item_key'].slice(9, 6)

        query = {
          func: 'booking-req-form-itm',
          adm_library: 'MIU50',
          adm_doc_number: adm_doc_number,
          adm_item_sequence: adm_item_sequence,
          exact_item: 'N'
        }.to_query
        Exlibris::Aleph::Config.base_url + '/F/?' + query
      end

      def process_mirlyn_item_info(item, info)
        {
          type: get_type(info),
          url: get_url(item, info),
          barcode: info['barcode'],
          location: info['location'],
          public_note: item['public_note'],
          callnumber: info['callnumber'],
          status: info['status'],
          enum: [info['enum_a'], info['enum_b'], info['enum_c']].compact,
          chron: [info['chron_i'], info['chron_j']].compact,
          info_link: item['info_link'],
          description: info['description'],
          summary_holdings: item['summary_holdings'],
          floor: Spectrum::FloorLocation.resolve(info['sub_library'], info['collection'], info['callnumber'])
        }
      end

      def process_hathitrust_item_info(item, info)
        {
          type: 'hathitrust',
          id: info['id'],
          handle_url: "http://hdl.handle.net/2027/#{info['id']}",
          source: info['source'],
          rights: info['rights'],
          status: info['status'],
          description: info['description'],
          summary_holdings: item['summary_holdings']
        }
      end
    end
  end
end
