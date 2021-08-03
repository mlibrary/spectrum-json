module Spectrum
  class Holding
    class FindingAidAction < NoAction
      def self.match?(item)
        item.record_has_finding_aid
      end
      def self.label
        'Go to Finding Aid'
      end
    end
  end
end

