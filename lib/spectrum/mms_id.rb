module Spectrum
  class MmsId
    attr_reader :prefix_code, :mms_id, :unique_id, :institution_code
    def initialize(mms_id)
      @mms_id = mms_id
      @prefix_code = mms_id[0,2]
      @institution_code = mms_id[-4,4]
      @unique_id = mms_id[2, mms_id.length - 6] #remove prefix and institution codes end
    end
    def doc_id
      #first 9 digits of unique_id
      @mms_id[2,9]
    end
    def to_s
      @mms_id
    end
  end
end
