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
        sorter = Hash.new {|hash,key| hash[key] = key}.tap do |hash|
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
        data.sort_by {|item| sorter[item[:location]]}
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

      def get_url(info)
        record = @request.id
        if info['can_request']
          query = {barcode: info['barcode'], getthis: 'Get this'}.to_query
          "https://mirlyn.lib.umich.edu/Record/#{record}/Hold?#{query}"
        elsif info['can_reserve']
          query = {barcode: info['barcode']}.to_query
          url = "https://mirlyn.lib.umich.edu/Record/#{record}/Request?#{query}"
        elsif info['can_book']
          query = {full_item_key: info['full_item_key']}.to_query
          url = "https://mirlyn.lib.umich.edu/Record/#{record}/Booking?#{query}"
        else
          nil
        end
      end

      def process_mirlyn_item_info(item, info)
        {
          type: get_type(info),
          url: get_url(info),
          barcode: info['barcode'],
          location: info['location'],
          callnumber: info['callnumber'],
          status: info['status'],
          enum: [ info['enum_a'], info['enum_b'], info['enum_c'] ].compact,
          chron: [ info['chron_i'], info['chron_j']].compact,
          info_link: item['info_link'],
          description: info['description'],
          summary_holdings: item['summary_holdings'],
          floor: Spectrum::FloorLocation.resolve(info['collection'], info['callnumber'])
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
          summary_holdings: item['summary_holdings'],
        }
      end
    end
  end
end
