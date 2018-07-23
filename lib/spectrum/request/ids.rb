# frozen_string_literal: true
require 'execjs'

module Spectrum
  module Request
    class Ids
      UNDERSCORE = '/tmp/search/node_modules/underscore/underscore.js'
      PRIDE = '/tmp/search/node_modules/pride/pride.execjs.js'
      PARSER  = 'Pride.FieldTree.parseField'
      DEFAULT_FIELD = 'all_fields'
      def initialize(req)
binding.pry
        underscore = IO.read(Rails.root.to_path + UNDERSCORE)
        pride = IO.read(Rails.root.to_path + PRIDE)
        context = ExecJS.compile(underscore + pride)
pp req.inspect
      end
    end
  end
end
