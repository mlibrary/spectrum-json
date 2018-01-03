module Spectrum
  class Holding
    def initialize(data, record, barcode)
      data[record].each do |item|
        next unless item['item_info']
        @item = item
        item['item_info'].each do |holding|
          next unless holding['barcode'] == barcode
          @holding = holding
        end
      end
      @record = record
      @barcode = barcode
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
  end
end
