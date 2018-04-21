# frozen_string_literal: true

require 'mail'

module Spectrum
  module Json
    class Email
      class << self
        attr_accessor :service, :client
        def configure!(config)
          self.service = config
          self.client = Mail
        end

        def text_header
          service.text_header + "\n"
        end

        def text_footer
          service.text_footer + "\n"
        end

        def html_header
          service.html_header
        end

        def html_footer
          service.html_footer
        end

        def text_format(messages)
          ret = text_header
          messages.each_with_index do |message, idx|
            ret << "Record #{idx + 1}:\n"
            ret << "#{title(message, "\n")}\n"
            ret << "#{url(message)}\n"
            ret << "*  Format: #{format(message, ', ')}\n"
            ret << "*  Author: #{author(message, ', ')}\n"
            ret << "*  Published: #{published(message)}\n"
            ret << "\n"
          end
          ret << text_footer
          ret
        end

        def format(message, glue)
          field(message, 'format', glue)
        end

        def author(message, glue)
          field(message, 'author', glue)
        end

        def published(message)
          field(message, 'published_brief')
        end

        def title(message, glue)
          field(message, 'title', glue)
        end

        def url(message)
          "#{field(message, 'base_url')}/#{field(message, 'id')}"
        end

        def html_format(messages)
          ret = '<div>'
          ret << html_header
          ret << '<ol>'
          messages.each_with_index do |message, idx|
            format_content = format(message, '</dd><dd>')
            author_content = author(message, '</dd><dd>')
            published_content = published(message)
            ret << '<li><article>'
            ret << '<header>'
            ret << "<div>Record #{idx + 1}:</div>"
            ret << "<div><a href='#{url(message)}'>#{title(message, '<br>')}</a></div>"
            ret << '</header>'
            ret << '<dl>'
            ret << "<dt>Format</dt><dd>#{format_content}</dd>" if format_content
            ret << "<dt>Author</dt><dd>#{author_content}</dd>" if author_content
            ret << "<dt>Published</dt><dd>#{published_content}</dd>" if published_content
            ret << '</dl>'
            ret << '</article></li>'
          end
          ret << '</ol>'
          ret << html_footer
          ret << '</div>'
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

        def message(email_to, email_from, messages)
          text_content = text_format(messages)
          html_content = html_format(messages)
          subject_content = service.subject
          client.deliver do
            to   email_to
            from email_from
            subject subject_content
            delivery_method :sendmail

            text_part do
              content_type 'text/plain; charset=UTF-8'
              body text_content
            end

            html_part do
              content_type 'text/html; charset=UTF-8'
              body html_content
            end
          end
        end
      end
    end
  end
end
