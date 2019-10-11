# frozen_string_literal: true

module Spectrum
  class Facet
    attr_accessor :field, :value

    # field is a string
    # value is a string, an array, or an array of arrays
    def initialize(field, value)
      self.field = field
      self.value = [value].flatten(1)
    end

    def fvf(filter_map)
      value.map do |item|
        "#{translate_field(filter_map)},#{summon_escape(item)},false"
      end
    end

    def empty?
      field.nil? || field.empty? || value.nil? || value.empty? || value.all?(&:empty?)
    end

    def query(filter_map, value_map)
      return nil if empty?
      solr_field = translate_field(filter_map)
      solr_value = translate_value(value_map[field] || value_map[solr_field] || {})
      if (field == 'date_of_publication' || solr_field == 'date_of_publication')
        solr_value = date_transform(new_value)
      end

      "#{solr_field}:(#{solr_value})"
    end

    def htso?
      field == 'search_only' && value.include?('true')
    end

    private
    def date_transform(item)
      item.match(/^before(\d+)$/)  { |m| return "[* TO #{m[1]}]" }
      item.match(/^after(\d+)$/)   { |m| return "[#{m[1]} TO *]" }
      item.match(/^(\d+)to(\d+)$/) { |m| return "[#{m[1]} TO #{m[2]}]" }
      item
    end

    def summon_escape(item)
      item.gsub(/,/, '\\,')
    end

    def solr_escape(string)
      RSolr.solr_escape(string).gsub(/\s+/, '\\ ')
    end

    def translate_field(mapping)
      mapping.fetch(field, field)
    end

    def translate_value(mapping)
      value.map do |item|
        [item].flatten.reject do |val|
          val == '*' || val == '\*'
        end.map do |val|
          solr_escape(mapping.fetch(val, val))
        end.join(' OR ')
      end.join(' AND ')
    end
  end
end
