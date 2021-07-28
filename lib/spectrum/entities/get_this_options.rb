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
      end.map{|x| Spectrum::Entities::GetThisOption.for(option: x, account: account, item: item).to_h}
    end
    def all
      @options
    end
  end
end
