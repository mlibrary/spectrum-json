module Spectrum
  module FieldTree
    class Field < Base
      TYPES = {
        'tag' => Spectrum::FieldTree::Tag,
        'field' => Spectrum::FieldTree::Field,
        'literal' => Spectrum::FieldTree::Literal,
        'special' => Spectrum::FieldTree::Special,
        'value_boolean' => Spectrum::FieldTree::ValueBoolean,
      }

      def params(field_map)
        ret = super
        unless @value.empty? || field_map.by_uid(@value).nil?
          ret.merge!(field_map.by_uid(@value).query_params)
        end
        ret
      end

      def query(field_map)
        val   = @children.map {|item| item.query(field_map)}.join(' ')
        if @value.empty? || field_map.by_uid(@value).nil? || field_map.by_uid(@value).query_field.empty?
          val
        else
          field = field_map.by_uid(@value).query_field
          if field.respond_to?(:map)
            "(#{field.map { |f| "#{f}:(#{val})" }.join(' OR ')})"
          else
            "#{field}:(#{val})"
          end
        end
      end
    end
  end
end
