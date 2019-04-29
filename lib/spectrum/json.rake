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

    desc "Search parsed search strings against all datastores publicized in spectrum"
    task :search, [:file, :datastore, :count] => [:environment] do |task, args|
      # 1 Construct a request for args[:datastore]
      tsv = CSV.read(args[:file], {col_sep: "\t", liberal_parsing: true})
      tsv.each do |row|
        raw_query = row[0]
        parsed_query = row[1]
        # 2 Add the query to the base
        # 3. Run the search, and get the results
        # 1.upto(args[:count]) do |i|
        #   row << result[i]
        # end
        puts CSV.generate_line(row, {col_sep: "\t", liberal_parsing: true})
      end
    end
  end
end
