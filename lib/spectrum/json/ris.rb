# frozen_string_literal: true

module Spectrum
  module Json
    class Ris
      class << self
        attr_accessor :fields
        def configure!(_config)
          self.fields = %i[
            type
            id
            title
            author
            publisher
            publication_year
            publication_place
            publication
            issue
            volume
            doi
            sn
            url
            sp
            ep
            er
          ]
        end

        def publication(item)
          single_valued(item, 'T2', 'publication_title')
        end

        def issue(item)
          single_valued(item, 'IS', 'issue')
        end

        def volume(item)
          single_valued(item, 'VL', 'volume')
        end

        def doi(item)
          single_valued(item, 'DO', 'doi')
        end

        def url(item)
          field(item, 'links').map do |link|
            link.find { |attr| attr['uid'] == 'href' }
          end.compact.map do |item|
            "L2  - #{item['value']}"
          end.join("\n")
        end

        def id(item)
          single_valued(item, 'ID', 'id')
        end

        def sn(item)
          %w[issn isbn eisbn eissn].each_with_object([]) do |uid, acc|
            acc << multi_valued(item, 'SN', uid)
          end.compact.reject(&:empty?).join("\n")
        end

        def cn(item)
          multi_valued(item, 'CN', 'callnumber')
        end

        def sp(item)
          single_valued(item, 'SP', 'start_page')
        end

        def ep(item)
          single_valued(item, 'EP', 'end_page')
        end

        def message(items)
          items.map { |item| ris(item) }.join("\n\n\n")
        end

        def title(item)
          multi_valued(item, 'TI', 'title')
        end

        def author(item)
          multi_valued(item, 'AU', 'author')
        end

        def publisher(item)
          multi_valued(item, 'PB', 'publisher')
        end

        def publication_year(item)
          multi_valued(item, 'PY', 'published_year')
        end

        def publication_place(item)
          multi_valued(item, 'PP', 'place_of_publication')
        end

        def ris(item)
          fields.map { |field| send(field, item) }.compact.reject(&:empty?).join("\n")
        end

        def type(item)
          single_valued(item, 'TY', 'format', 'JOUR')
        end

        def er(_item)
          'ER  -'
        end

        def single_valued(item, tag, uid, default = nil)
          value = field(item, uid).first || default
          return nil unless value
          "#{tag}  - #{value}"
        end

        def multi_valued(item, tag, uid)
          field(item, uid).map { |value| "#{tag}  - #{value}" }.join("\n")
        end

        def field(message, uid, glue = nil)
          if glue
            field_value(message, uid).join(glue)
          else
            field_value(message, uid)
          end
        end

        def field_value(message, uid)
          values = message.find { |field| field[:uid] == uid }
          return Array(values[:value]) if values
          []
        end
      end
    end
  end
end
