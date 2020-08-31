#Has same interface as Spectrum::Utility::HttpClient
module Spectrum
  module Utility
    class ItemPicker
      def item(request:, client: Spectrum::Utility::AlmaClient.new)
        return Spectrum::AvailableOnlineHolding.new(request.id) if request.barcode == 'available-online'

         response = client.get("/items", query: {item_barcode: request.barcode})
        case response.code
        when 200
          Spectrum::Item.new(response.parsed_response)
        else
          Spectrum::NullItem.new(request.barcode)
        end
      end
    end
  end
end
