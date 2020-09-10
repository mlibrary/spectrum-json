# frozen_string_literal: true

#Item: Thing that has a barcode
#has same interface as Holding. Can go straight for item based on barcode. Works with Alma API.
module Spectrum
  class Item

    REOPENED = [
      'HATCH',
      'HSRS',
      'BUHR',
      'SHAP',
      'SCI',
    ]

    def initialize(item_data)
      @bib = item_data['bib_data']
      @holding = item_data['holding_data']
      @item = item_data['item_data']
    end
    def library
      @item.dig('library','value')
    end
    def description
      @item['description']
    end

    def collection
      @item.dig('location','value')
    end
    def barcode
      @item['barcode'] || ''
    end

    def record
      @bib['mms_id'] || ''
    end
    
    def inventory_number
      @item['inventory_number']
    end

    def id
      record
    end

    def callnumber
      call_number
    end
    def call_number
      @holding['call_number'] || ''
    end

    def notes
      @item['description'] || ''
    end

    def issue
      @item['description'] || ''
    end

    def full_item_key
      #@holding['full_item_key'] || ''
      @item['pid'] || ''
    end

    def can_book?
      #@holding['can_book']
    end

    def can_reserve?
      #@holding['can_reserve']
    end

    def can_request?
      #@holding['can_request']
    end

    def circulating?
      can_request?
    end

    def building_use_only?
      #status.start_with?('Building use only')
    end

    #FIXME check after test load
    def on_shelf?
      #status.start_with?('On shelf') || building_use_only?
      @item.dig('base_status','value') == '1' ? true : false
    end

    def mobile?
      #!building_use_only?
    end

    def off_shelf?
      !on_shelf?
    end

    def missing?
      #status.start_with?('missing')
    end

    def known_off_shelf?
      #return false if missing? || checked_out?
      #off_shelf?
    end

    def on_site?
      !off_site?
    end

    def checked_out?
      #status.start_with?('Checked out')
    end

    def off_site?
      #@holding['location'].start_with?('Offsite', '- Offsite')
      @item['library']['desc'].start_with?('Offsite') || @item['location']['desc'].include?('Offsite')
    end

    def reopened?
      REOPENED.include?(@item['library']['value'])
    end

    def location
      [@item['library']['value'], @item['location']['value']].compact.join(',')
    end

    def status
      #@holding['status']
    end

  end

  class NullItem < Spectrum::Item

    def initialize(barcode)
      @bib = Hash.new
      @holding = Hash.new
      @item = {'barcode' => barcode}
    end

    def can_book?
      false
    end

    def can_reserve?
      false
    end

    def can_request?
      false
    end

    def off_site?
      false
    end
    def status
      ''
    end
    def location
      ''
    end

    def reopened?
      false
    end

  end
end
