module Spectrum
  class FacetList
    attr_reader :data

    def initialize(data)
     @data = data
    end

    def spectrum
      @data || {}
    end

    def fvf filter_map = {}
      ret = []
      if @data
        @data.each_pair do |key, value|
          if value.is_a?(Array)
            value.each do |item|
              ret << "#{filter_map[key] || key},#{item},false"
            end
          else
            ret << "#{filter_map[key] || key},#{value},false"
          end
        end
      end
      ret
    end

    def query(filter_map = {}, value_map = {})
      ret = []
      if @data
        @data.each_pair do |key, value|
          key = filter_map[key] if filter_map[key]
          value = Array(value).map do |v|
            value_map.fetch(key, {}).fetch(v, v)
          end.reject do |v|
            v == '*'
          end.map do |v|
            solr_escape(v)
          end.join(' AND ')

          if key == 'date_of_publication'
            value.match(/^before(\d+)$/) do |m|
              value = "[* TO #{m[1]}]"
            end
            value.match(/^after(\d+)$/) do |m|
              value = "[#{m[1]} TO *]"
            end
            value.match(/^(\d+)to(\d+)$/) do |m|
              value = "[#{m[1]} TO #{m[2]}]"
            end
          end
          ret << "#{key}:(#{value})" unless value.empty?
        end
      end
      ret
    end

    private
    def solr_escape string
      RSolr.solr_escape(string).gsub(/\s+/, "\\ ")
    end
  end
end
