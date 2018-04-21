# frozen_string_literal: true

module Spectrum
  module Json
    class Twilio
      class << self
        attr_accessor :service, :client
        def configure!(config)
          self.service = config.service
          self.client  = ::Twilio::REST::Client.new(config.account, config.token)
          self
        end

        def message(to, messages)
          return [] unless to =~ /^[0-9]{10,10}$/
          messages.each_with_index.map do |message, index|
            client.messages.create(to: "1#{to}", from: service, body: format(message, index))
          end
        end

        def format(message, index = nil)
          ret = ''
          ret << "Record #{index + 1}: " if index
          ret << title(message)
          ret << link(message)
          ret
        end

        def field(message, uid, glue = nil)
          if glue
            field_value(message, uid).join(glue)
          else
            field_value(message, uid).first
          end
        end

        def field_value(message, uid)
          Array(message.find { |field| field[:uid] == uid }[:value])
        end

        def title(message)
          " Title: #{field(message, 'title', "\n")}"
        end

        def link(message)
          " Link: #{field(message, 'base_url')}/#{field(message, 'id')}"
        end
      end
    end
  end
end
