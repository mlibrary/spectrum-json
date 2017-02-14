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
      def query field_map = {}
        if @value.empty? || field_map[@value].empty?
          @children.map {|item| item.query(field_map)}.join(' ')
        else
          "#{field_map[@value] || @value}:(#{@children.map {|item| item.query(field_map)}.join(' ')})"
        end
      end
    end
  end
end
