module Spectrum
  class Holding
    attr_reader :holding, :record, :barcode

    def initialize(data, record, barcode)
      @holding = extract_holding(data, record, barcode) || barcode_not_found
      @record  = record
      @barcode = barcode
    end

    def id
      record
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

    def on_shelf?
      @holding['status'].start_with?('On shelf')
    end

    def on_site?
      ! off_site?
    end

    def off_site?
      @holding['location'].start_with?('Off-site')
    end

    def location
      @holding['location']
    end

    def status
      @holding['status']
    end

    private
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
        'location' => '',
      }
    end
  end
end
