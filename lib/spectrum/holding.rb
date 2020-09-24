# frozen_string_literal: true

module Spectrum
  class Holding

    REOPENED = [
      'HATCH',
      'HSRS',
      'BUHR',
      'SHAP',
      'SCI',
      'UGL',
      'FINE',
      'AAEL',
      'MUSIC',
    ]

    SHAPIRO_AND_AAEL_PICKUP = [
      'OFFS',
      'ELLS',
      'STATE',
    ]

    SHAPIRO_PICKUP = [
      'HATCH',
      'SHAP',
      'SCI',
      'UGL',
      'FINE',
      'BUHR',
    ]

    AAEL_PICKUP = [ 'AAEL' ]

    MUSIC_PICKUP = [ 'MUSIC' ]

    FLINT_PICKUP = [ 'FLINT' ]

    ETAS_START = 'Full text available,'

    attr_reader :holding, :record, :barcode

    def initialize(data, record, barcode)
      @holding = extract_holding(data, record, barcode) || barcode_not_found
      @item    = data[record]
      @record  = record
      @barcode = barcode
      @etas_ids = extract_etas_ids(@item)
    end

    def self.for(request:, source:)
      return  Spectrum::AvailableOnlineHolding.new(request.id) if request.barcode == 'available-online'
      url = source.holdings + request.id
      response = HTTParty.get(url)
      Spectrum::Holding.new(response.parsed_response, request.id, request.barcode)
    end

    def id
      record
    end

    def callnumber
      @holding['callnumber'] || ''
    end

    def notes
      @holding['description'] || ''
    end

    def issue
      @holding['description'] || ''
    end

    def full_item_key
      @holding['full_item_key'] || ''
    end

    def can_book?
      @holding['can_book']
    end

    def can_reserve?
      @holding['can_reserve']
    end

    def can_request?
      @holding['can_request']
    end

    def circulating?
      can_request?
    end

    def not_building_use_only?
      !building_use_only?
    end

    def building_use_only?
      status.start_with?('Building use only')
    end

    def on_shelf?
      status.start_with?('On shelf') || building_use_only?
    end

    def mobile?
      !building_use_only?
    end

    def off_shelf?
      !on_shelf?
    end

    def missing?
      status.start_with?('missing')
    end

    def not_missing?
      !missing?
    end

    def known_off_shelf?
      return false if missing? || checked_out?
      off_shelf?
    end

    def on_site?
      !off_site?
    end

    def checked_out?
      status.start_with?('Checked out')
    end

    def not_checked_out?
      !checked_out?
    end

    def off_site?
      @holding['location'].start_with?('Offsite', '- Offsite')
    end

    def contactless_pickup?
      shapiro_pickup?
    end

    def shapiro_pickup?
      SHAPIRO_PICKUP.include?(@holding['sub_library'])
    end

    def shapiro_and_aael_pickup?
      SHAPIRO_AND_AAEL_PICKUP.include?(@holding['sub_library'])
    end

    def aael_pickup?
      AAEL_PICKUP.include?(@holding['sub_library'])
    end

    def music_pickup?
      MUSIC_PICKUP.include?(@holding['sub_library'])
    end

    def standard_pickup?
      flint_pickup?
    end

    def flint_pickup?
      FLINT_PICKUP.include?(@holding['sub_library'])
    end

    def flint?
      ['FLINT'].include?(@holding['sub_library'])
    end

    def not_flint?
      !flint?
    end

    def not_reopened?
      !reopened?
    end

    def reopened?
      REOPENED.include?(@holding['sub_library'])
    end

    def available?
      reopened? && not_checked_out? && not_missing?
    end

    def unavailable?
      !available?
    end

    def location
      [@holding['sub_library'], @holding['collection']].compact.join(',')
    end

    def status
      @holding['status']
    end

    def not_pickup_or_checkout?
      not_pickup? || checked_out? || missing? || building_use_only?
    end

    def not_flint_or_checkout?
      not_flint? || checked_out? || missing? || building_use_only?
    end

    def not_pickup?
      !(shapiro_pickup? || aael_pickup? || music_pickup? || shapiro_and_aael_pickup?)
    end

    def not_flint_and_etas?
      !(flint? && etas?)
    end

    def flint?
      ['FLINT'].include?(@holding['sub_library'])
    end

    def not_etas?
      !etas?
    end

    def etas?
      # We decided on bib-level etas decisions, but if that changes.
      # @etas_ids['mdp.' + barcode]
      !@etas_ids.empty?
    end

    private

    def extract_etas_ids(items)
      ht_item = items.find do |item|
        ['HathiTrust Digital Library'].include?(item['location'])
      end
      return {} unless ht_item
      return Hash.new(true) if ht_item['status'].start_with?(ETAS_START)
      return {} unless ht_item['item_info']
      ht_item['item_info'].inject({}) do |acc, info|
        acc.tap do |acc|
          acc[info['id']] = info['status'].start_with?(ETAS_START)
        end
      end
    end

    def extract_holding(data, record, barcode)
      data[record].each do |item|
        next unless item['item_info']
        item['item_info'].each do |holding|
          return holding if holding['barcode'] == barcode
        end
      end
    end

    def barcode_not_found
      {
        'can_book' => false,
        'can_reserve' => false,
        'can_request' => false,
        'status' => '',
        'location' => ''
      }
    end
  end
end
