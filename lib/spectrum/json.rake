require 'csv'
require 'net/http'
require 'execjs'

namespace :spectrum do
  namespace :json do
    desc "Parse search strings into json objects"
    task :parse, [:file, :column] do |task, args|

      underscore = Net::HTTP.get(URI.parse('https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.9.1/underscore.js')).encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      pride      = Net::HTTP.get(URI.parse('https://raw.githubusercontent.com/mlibrary/pride/master/pride.execjs.js')).encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      parser     = 'Pride.Parser.parse'
      context    = ExecJS.compile(underscore + pride)

      col = args[:column].to_i
      tsv = CSV.read(args[:file], {col_sep: "\t", liberal_parsing: true, headers: true})
      tsv.each do |row|
        raw_query = row[col]
        parsed_query = begin
          context.call(parser, raw_query)
        rescue
          context.call(parser, '"' + raw_query.gsub(/"/, '') + '"')
        end
        puts CSV.generate_line([raw_query, parsed_query.to_json], {col_sep: "\t", liberal_parsing: true, headers: true})
      end
    end
  end
end
