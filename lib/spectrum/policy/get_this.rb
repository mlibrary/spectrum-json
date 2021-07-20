# frozen_string_literal: true

require 'yaml'
require 'date'

module Spectrum
  module Policy
    class GetThis
      class Grant
        attr_reader :attribute, :features
        def initialize(attribute, features)
          @attribute = attribute
          @features = features
        end

        def allow(account, bib, item)
          h = { 'patron' => account, 'bib' => bib, 'holding' => item }
          features.all? { |feature| h[@attribute].send(feature) }
        end
      end

      class Option
        attr_reader :label, :service_type, :duration, :description, :tip, :faq, :form,
                    :grants, :weight, :orientation

        def initialize(config)
          @label = config['label']
          @service_type = config['service_type']
          @duration = config['duration']
          @description = config['description']
          @orientation = config['orientation'] || ''
          @tip = config['tip']
          @faq = config['faq']
          @form = config['form']
          @grants = config['grants'].map do |attribute, features|
            Grant.new(attribute, features)
          end
          @weight = config['weight'] || 0
        end

        def resolve(account, bib, item)
          return nil unless allow?(account, bib, item)
          replace(account, bib, item)
        end

        def allow?(account, bib, item)
          grants.all? { |grant| grant.allow(account, bib, item) }
        end

        def replace(account, bib, item)
          new_hash = Marshal.load(Marshal.dump(to_h))
          if new_hash['form']
            new_hash['form']['action'] = replace_string(new_hash['form']['action'], account, bib, item)
            new_hash['form']['fields'].each do |field|
              field['value'] = replace_string(field['value'], account, bib, item) if field['value']
            end
          end
          new_hash['orientation'] = replace_string(new_hash['orientation'], account, bib, item)
          new_hash
        end

        def replace_string(input_string, account, bib, item)
          input_string
            .gsub('{$barcode}', item.barcode)
            .gsub('{$record_id}', item.doc_id)
            .gsub('{$holding_id}', item.holding_id)
            .gsub('{$item_id}', item.item_id)
            .gsub('{$patron_id}', account.id)
            .gsub('{$patron_name}', account.name || '')
            .gsub('{$email}', account.email || '')
            .gsub('{$two_months_from_today}', (::DateTime.now >> 2).strftime('%Y-%m-%d'))
            .gsub('{$accession_number}', bib.accession_number || '')
            .gsub('{$isbn}', bib.isbn || '')
            .gsub('{$issn}', bib.issn || '')
            .gsub('{$title}', bib.title || '')
            .gsub('{$rft.au}', bib.author || '')
            .gsub('{$date}', bib.date || '')
            .gsub('{$rft.pub}', bib.pub || '')
            .gsub('{$rft.place}', bib.place || '')
            .gsub('{$rft.edition}', bib.edition || '')
            .gsub('{$callnumber}', item.callnumber || '')
            .gsub('{$aleph_location}', item.location || '')
            .gsub('{$notes}', item.public_note || '')
#            .gsub('{$rft.issue}', item.issue)
#            .gsub('{$full_item_key}', item.full_item_key)
#            .gsub('{$aleph_item_status}', item.status)
        end

        def to_h
          {
            'label' => label,
            'service_type' => service_type,
            'duration' => duration,
            'description' => description,
            'orientation' => orientation,
            'tip' => tip,
            'faq' => faq,
            'form' => form
          }
        end
      end

      class << self
        attr_reader :options

        def load_config(config_file)
          @options = YAML.load(ERB.new(File.read(config_file)).result).map do |option|
            Option.new(option)
          end
        end

        def options
          @options ||= {}
        end

        def resolve(account, bib, item)
          options.map { |option| option.resolve(account, bib, item) }.compact
        end
      end

      attr_reader :account, :bib, :item

      def initialize(account, bib, item)
        @account = account
        @bib     = bib
        @item    = item
      end

      def resolve
        self.class.resolve(account, bib, item)
      end

      private

      def options
        self.class.options
      end
    end
  end
end
