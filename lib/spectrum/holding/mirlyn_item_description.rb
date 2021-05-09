module Spectrum
  class Holding
    class MirlynItemDescription
      attr_reader :temp_location, :description
      def initialize(item:)
        @item = item
        @description = item.description
      end
      def to_h
        { format_type => value }
      end

      def self.for(item:)
        has_description =  !(item.description.nil? || item.description.empty?)
        if item.temp_location? && has_description
          TemporaryWithDescription.new(item: item)
        elsif item.temp_location?
          TemporaryNoDescription.new(item: item)
        elsif has_description
          DescriptionNotTemporary.new(item: item)
        else #Not Temporary and No Description
          MirlynItemDescription.new(item: item)
        end
      end

      private

      def value
        ''
      end
      
      def format_type
        :text
      end

      def temp_location_string
        "In a Temporary Location"
      end

      class TemporaryWithDescription < MirlynItemDescription
        def value
          "<div>#{@description}</div><div>#{temp_location_string}</div>"
        end
        def format_type
          :html
        end
      end

      class TemporaryNoDescription < MirlynItemDescription
        def value
          temp_location_string
        end
      end
      class DescriptionNotTemporary < MirlynItemDescription
        def value
          @description
        end
      end

      private_constant :TemporaryWithDescription
      private_constant :TemporaryNoDescription
      private_constant :DescriptionNotTemporary
    end
  end
end

