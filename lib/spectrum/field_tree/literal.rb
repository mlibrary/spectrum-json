module Spectrum
  module FieldTree
    class Literal < ChildFreeBase
      def query(field_map = {})
        #RSolr.solr_escape(@value.to_s)
        @value.to_s
      end
    end
  end
end
