module Spectrum
  class Holding
    class NoAction < Action
      def self.match?(item, contactless_pickup = ['HATCH','FINE','BUHR','SCI','SHAP','AAEL','MUSIC','OFFS','STATE'])
        open = contactless_pickup.concat(['SPEC','BENT','CLEM'])
        return true if !open.include?(item.library) 

        return true if ['06','07'].include?(item.item_policy)

        return true if (item.process_type && item.process_type != 'MISSING')

        case item.library
        when 'AAEL'
          ['04','05'].include?(item.item_policy)
        when 'FINE'
          ['03','04','05'].include?(item.item_policy)
        when 'FLINT'
          ['04','05','10'].include?(item.item_policy)
        when 'MUSM'
          ['03'].include?(item.item_policy)
        when 'HATCH'
          item.location == 'PAPY'
        when 'BTSA'
          ['08'].include?(item.item_policy)
        when 'CSCAR'
          ['08'].include?(item.item_policy)
        when 'DHCL'
          ['BOOK', 'OVR'].include?(item.location) && item.item_policy == '08'
        else
          false
        end
      end
      def self.label
        'N/A'
      end
      def finalize
        { text: label }
      end
    end
  end
end
