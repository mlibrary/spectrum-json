# frozen_string_literal: true

module Spectrum

  def self.Facet(key, value, queryable_uids)
    if (queryable_uids || []).include?(key)
      Facet.new(key, value)
    else
      SilentFacet.new(key, value)
    end
  end

  class FacetList
    attr_reader :data

    def find(field)
      [data.map { |key,value| key == field && value }].flatten(2).compact
    end

    def initialize(default_facets, request_facets, queryable_uids)
      @data = (default_facets || {}).merge(request_facets || {}).map do |key, value|
        Spectrum::Facet(key, value, queryable_uids)
      end
    end

    def spectrum
      data.inject({}) do |memo, facet|
        memo.merge({facet.field => facet.value})
      end
    end

    def fvf(filter_map = {})
      data.map { |filter| filter.fvf(filter_map) }.flatten
    end

    def query(filter_map = {}, value_map = {})
      data.map { |filter| filter.query(filter_map, value_map) }.compact.reject(&:empty?)
    end

    def htso?
      data.any? { |filter| filter.htso? }
    end

  end
end
