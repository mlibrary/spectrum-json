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
        if @value.empty? || field_map.by_uid(@value).nil?
          @children.map {|item| item.query(field_map)}.join(' ')
        else
          "#{field_map.by_uid(@value).field}:(#{@children.map {|item| item.query(field_map)}.join(' ')})"
        end
      end
    end
  end
end
