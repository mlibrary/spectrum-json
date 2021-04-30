require 'json'

class Spectrum::LibLocDisplay
  def self.configure(json_file)
    @config = JSON.parse(File.read(json_file))
    self
  end
  def self.normalize_location(library, location)
    "#{library} #{location}".strip.upcase
  end

  def self.link(library, location)
    id = normalize_location(library, location)
    @config.find{|x| x["id"] == id}&.dig("link")
  end

  def self.text(library, location)
    id = normalize_location(library, location)
    @config.find{|x| x["id"] == id}&.dig("text")
  end

end


