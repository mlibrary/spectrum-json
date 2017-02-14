module Spectrum
  module FieldTree
    class Base
      TYPES = {
        'tag' => Spectrum::FieldTree::Tag,
        'field' => Spectrum::FieldTree::Field,
        'literal' => Spectrum::FieldTree::Literal,
        'special' => Spectrum::FieldTree::Special,
        'value_boolean' => Spectrum::FieldTree::ValueBoolean,
        'field_boolean' => Spectrum::FieldTree::FieldBoolean,
      }

      def initialize data
        @type  = data['type']
        @value = data['value']
        @children = data['children'] || []
        @children = @children.map {|child| Spectrum::FieldTree.new(child, self.class::TYPES)}
      end

      def valid?
        @children.all?(&:valid?)
      end

      def spectrum
        ret = {
          type: @type,
          value: @value
        }
        ret.merge!({
          children: @children.map(&:spectrum)
        }) unless @children.empty?
        ret
      end

      def query(field_map = {}) 
        @value
      end
    end
  end
end
