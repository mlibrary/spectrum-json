# frozen_string_literal: true

module Spectrum
  module Request
    class File
      def initialize(request)
        @raw = CGI.unescape(request.raw_post)
        @data = JSON.parse(@raw)
        @username = request.env['HTTP_X_REMOTE_USER'] || ''
        @items = nil
      end

      def items
        return @items if @items
        ret = []
        each_item do |item|
          ret << item
        end
        @items = ret
      end

      def each_item
        @data.each_pair do |focus_uid, data|
          focus = Spectrum::Json.foci[focus_uid]
          next unless focus
          data['records'].each do |id|
            record = focus.fetch_record(Spectrum::Json.sources, id)
            yield record + [{ uid: 'base_url', value: data['base_url'] }]
          end
        end
      end

      def each_focus
        @data.each_pair do |focus, ids|
          yield Spectrum::Json.foci[focus], ids
        end
      end

      def logged_in?
        !@username.empty?
      end
    end
  end
end
