# frozen_string_literal: true

module Spectrum
  class FacetList
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def spectrum
      @data || {}
    end

    def fvf(filter_map = {})
      ret = []
      @data&.each_pair do |key, value|
        if value.is_a?(Array)
          value.each do |item|
            ret << "#{filter_map[key] || key},#{item},false"
          end
        else
          ret << "#{filter_map[key] || key},#{value},false"
        end
      end
      ret
    end

    def query(filter_map = {}, value_map = {})
      ret = []
      @data&.each_pair do |original_key, value|
        key = filter_map.fetch(original_key, original_key)
        value = Array(value).map do |v|
          mapped_value = if value_map.has_key?(original_key)
            value_map.fetch(original_key, {}).fetch(v, v)
          else
            value_map.fetch(key, {}).fetch(v, v)
          end
          [mapped_value].flatten.map {|v| solr_escape(v)}.join(' OR ')
        end.reject do |v|
          v == '*' || v == '\*'
        end.join(' AND ')

        if key == 'date_of_publication' || original_key == 'date_of_publication'
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
      ret
    end

    private

    def solr_escape(string)
      RSolr.solr_escape(string).gsub(/\s+/, '\\ ')
    end
  end
end
