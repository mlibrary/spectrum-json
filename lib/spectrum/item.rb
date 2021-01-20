# frozen_string_literal: true

module Spectrum
  class Item

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
      'RMC',
      'OFFS',
      'STATE',
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
      'HSRS',
      'RMC',
      #'OFFS',  # This is in SHAPIRO_AND_AAEL
      #'STATE', # This is in SHAPIRO_AND_AAEL
    ]

    AAEL_PICKUP = [ 'AAEL' ]

    MUSIC_PICKUP = [ 'MUSIC' ]

    FLINT_PICKUP = [ 'FLINT' ]

    ETAS_START = 'Full text available,'

    attr_reader :holding, :id 

    def initialize(id:, holdings:, item:)
      @item = item || barcode_not_found # single item from getHoldings.pl element
      @holdings  = holdings  #single element from getHoldings.pl
      @id = id #doc_id
      @etas_ids = extract_etas_ids(@holdings)
    end

    def self.for_get_this(request:, source:)
      return  Spectrum::AvailableOnlineHolding.new(request.id) if request.barcode == 'available-online'
      url = source.holdings + request.id
      response = HTTParty.get(url)
      Spectrum::Item.for_barcode(response.parsed_response, request.id, request.barcode)
    end

    def self.for_barcode(data, record, barcode)
      holdings    = data[record]  #single element from getHoldings.pl
      item = holdings.map do |holding|
        next unless holding['item_info']
        holding['item_info'].find do |item|
          item['barcode'] == barcode
        end
      end.compact.first
      Spectrum::Item.new(id: record, holdings: holdings, item: item)
    end

    def record
      @id
    end

    def barcode
      @item['barcode']
    end

    def callnumber
      @item['callnumber'] || ''
    end

    def description
      @item['description'] || ''
    end
    def temp_location?
      @item['temp_location'] 
    end
    def temp_location
      @item['temp_loc'] || ''
    end
    def notes
      @item['description'] || ''
    end

    def issue
      @item['description'] || ''
    end

    def full_item_key
      @item['full_item_key'] || ''
    end

    def can_book?
      @item['can_book']
    end

    def can_reserve?
      @item['can_reserve']
    end

    # HSRS reports can_request false in getHoldings.pl
    def can_request?
      @item['can_request'] || ['HSRS'].include?(@item['sub_library'])
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
      status.start_with?('Checked out') ||
        status.start_with?('Recalled') ||
        status.start_with?('Requested')
    end

    def not_checked_out?
      !checked_out?
    end

    def off_site?
      @item['location'].start_with?('Offsite', '- Offsite')
    end

    def contactless_pickup?
      shapiro_pickup?
    end

    def shapiro_pickup?
      SHAPIRO_PICKUP.include?(@item['sub_library'])
    end

    def shapiro_and_aael_pickup?
      SHAPIRO_AND_AAEL_PICKUP.include?(@item['sub_library'])
    end

    def aael_pickup?
      AAEL_PICKUP.include?(@item['sub_library'])
    end

    def music_pickup?
      MUSIC_PICKUP.include?(@item['sub_library'])
    end

    def standard_pickup?
      flint_pickup?
    end

    def flint_pickup?
      FLINT_PICKUP.include?(@item['sub_library'])
    end

    def flint?
      ['FLINT'].include?(@item['sub_library'])
    end

    def not_flint?
      !flint?
    end

    def not_reopened?
      !reopened?
    end

    def reopened?
      REOPENED.include?(@item['sub_library'])
    end

    def available?
      reopened? && not_checked_out? && not_missing?
    end

    def unavailable?
      !available?
    end

    def unavailable_or_flint?
      unavailable? || flint?
    end

    def location
      [@item['sub_library'], @item['collection']].compact.join(',')
    end

    def status
      @item['status']
    end

    def not_pickup_or_checkout?
      not_pickup? || checked_out? || missing? || building_use_only?
    end

    def not_flint_or_checkout?
      not_flint? || checked_out? || missing? || building_use_only?
    end

    def not_pickup?
      !(shapiro_pickup? || aael_pickup? || music_pickup? || shapiro_and_aael_pickup? || flint_pickup?)
    end

    def not_flint_and_etas?
      !(flint? && etas?)
    end

    def flint?
      ['FLINT'].include?(@item['sub_library'])
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
