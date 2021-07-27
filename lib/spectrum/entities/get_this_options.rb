require 'yaml'
class Spectrum::Entities::GetThisOptions
  class << self
    def configure(options)
      @options = YAML.load_file(options)
    end
    def options_for(account, bib, item)
      attributes = { 'patron' => account, 'bib' => bib, 'holding' => item }
      @options.select do |option|
        option['grants'].map do |attribute, features | 
          features.all? {|feature| attributes[attribute].send(feature)}
        end.any?
      end
    end
    def all
      @options
    end
  end
end
