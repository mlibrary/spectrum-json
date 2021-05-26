module Spectrum
  class Presenters::PhysicalItem
    def initialize(item:, bib_record: )
      @bib_record = bib_record
      @item = item #Entities::MirlynItem
    end
    def to_a(action: Spectrum::Holding::Action.for(bib_record: @bib_record, item: @item),
             description: Spectrum::Holding::PhysicalItemDescription.for(item: @item),
             intent: nil, icon: nil)
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
      return callnumber unless (inventory_number = @item.inventory_number)
      return callnumber unless callnumber.start_with?('VIDEO')
      [callnumber, inventory_number].join(' - ')
    end
  end
end
