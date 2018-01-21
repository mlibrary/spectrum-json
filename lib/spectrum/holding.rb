module Spectrum
  class Holding
    attr_reader :holding, :record, :barcode

    def initialize(data, record, barcode)
      @holding = extract_holding(data, record, barcode) || barcode_not_found
      @item    = data[record]
      @record  = record
      @barcode = barcode
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
      status.start_with?('On shelf') || status.start_with?('Building use only')
    end

    def off_shelf?
      !on_shelf?
    end

    def missing?
      status.start_with?('missing')
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

    def off_site?
      @holding['location'].start_with?('Off-site')
    end

    def location
      [@holding['sub_library'], @holding['collection']].compact.join(',')
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
