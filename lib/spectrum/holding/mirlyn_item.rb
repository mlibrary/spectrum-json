module Spectrum
  class Holding
    class MirlynItem
      def initialize(holding_input:,item_info:, 
                     item_factory: lambda{|id, holdings, item| Spectrum::Item.new(id: id, holdings: holdings, item: item) }
                    )
        @holding = holding_input.holding
        @raw = holding_input.raw
        @id = holding_input.id
        @bib_record = holding_input.bib_record
        @item = item_factory.call(@id, @raw, item_info)
        @item_info = item_info
      end
      def to_a(action: Spectrum::Holding::Action.new(@id, @id, @bib_record, @holding, @item_info),
               description: Spectrum::Holding::MirlynItemDescription.for(item: @item),
               intent: Aleph.intent(@item.status), icon: Aleph.icon(@item.status))
        [
          action.finalize,
          description.to_h,
          {
            text: @item.status || 'N/A',
            intent: intent || 'N/A',
            icon: icon || 'N/A'
          },
          { text: call_number || 'N/A' }
        ]
      end
      private 
      def call_number
        return nil unless (callnumber = @item.callnumber)
        return callnumber unless (inventory_number = @item_info['inventory_number'])
        return callnumber unless callnumber.start_with?('VIDEO')
        [callnumber, inventory_number].join(' - ')
      end
    end
  end
end
