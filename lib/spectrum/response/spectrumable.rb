module Spectrum
  module Response
    module Spectrumable
      extend ActiveSupport::Concern

      def initialize(args = {})
        @data = args
      end

      def spectrum
        if @data.respond_to?(:spectrum)
          @data.spectrum
        else
          @data
        end
      end
    end
  end
end
