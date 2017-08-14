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

    def query filter_map = {}
      ret = []
      if @data
        @data.each_pair do |key, value|
          if value.is_a?(Array)
            value = value.map { |val| solr_escape(val)}.join(' AND ')
          else
            value = solr_escape(value)
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
