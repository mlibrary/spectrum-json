module Spectrum::Entities
  class NewHathiHolding
    def initialize(bib_record)
      @bib_record = bib_record
      @holding = bib_record.hathi_holding
    end
    #
    # Things that respond with the empty string
    [:callnumber, :sub_library, :collection].each do |name|
      define_method(name) do
        ''
      end
    end
    def info_link
      nil
    end
    def location
      @holding.library
    end
    def mms_id
      @bib_record.mms_id
    end
    def doc_id
      mms_id
    end
    def items 
      @holding.items.map{|x| Spectrum::Entities::NewHathiItem.new(self, x) }
    end
    def id
      items.first.id if items.count == 1
    end
    def status
      items.first.status if items.count == 1
    end
    
  end
  class NewHathiItem
    extend Forwardable
    def_delegators :@holding, :mms_id, :doc_id, :callnumber, :sub_library, :collection, :holding_id, :location

    def initialize(holding, item)
      @holding = holding
      @item = item
    end
    
    [:description, :source, :rights, :id].each do |name|
      define_method(name) do
        @item.public_send(name)
      end
    end

    def record
      @holding.mms_id
    end
    def status
      #TBD reimplement getHoldings stuff??? 
      'Full Text'
    end
  end
end
