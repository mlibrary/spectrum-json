module Spectrum
  class Holding
    class ReserveThisAction < Action
      def self.label
        'Reserve This'
      end

      def self.match?(item)
        item.library == 'FVL'
      end

      def finalize
        super.merge(
          href: "https://get-this.lib.umich.edu/#{@item.barcode}"
        )
      end
    end
  end
end
