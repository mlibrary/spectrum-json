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
          if value.is_a?(Array)
            value = value.map { |val| solr_escape(value_map.fetch(val, val))}.join(' AND ')
          else
            value = solr_escape(value_map.fetch(value, value))
          end
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
          ret << "#{filter_map[key] || key}:(#{value})"
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
