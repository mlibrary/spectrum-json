module Spectrum
  module Json
    module Schema
      NUMBER  = {'type' => 'number'}
      OBJECT  = {'type' => 'object'}
      STRING  = {'type' => 'string'}
      BOOLEAN = {'type' => 'boolean'}
      INTEGER = {'type' => 'integer'}

			SCALAR = {'anyOf' => [STRING, NUMBER, BOOLEAN]}

      FIELD_TREE = {
        'type' => 'object',
        'id' => 'field_tree',
        'properties' => {
          'type' => STRING,
          'value' => STRING,
          'children' => {
            'type' => 'array',
            'items' => {
              '$ref' => 'field_tree',
            }
          },
        }
      }

      REQUEST = {
        'type' => 'object',
        'properties' => {
          'uid' => STRING,
          'request_id' => SCALAR,
          'start' => INTEGER,
          'count' => INTEGER,
          'field_tree' => FIELD_TREE,
          'facets' => OBJECT,
          'settings' => OBJECT,
        },
      }

      FACET_REQUEST = REQUEST.merge({ })

      def self.validate(type, data)
        JSON::Validator.validate(schema(type), data)
      end

      def self.validate!(type, data)
        JSON::Validator.validate!(schema(type), data)
      end

      private
      def self.schema(type) 
        case type
        when :request then REQUEST
        when :facet_request then FACET_REQUEST
        end
      end
    end
  end
end
