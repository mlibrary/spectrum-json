require 'rails'
require 'exlibris-aleph'

module Spectrum
  module Json
    class Railtie < Rails::Railtie
      initializer 'spectrum-json.initialize' do
        Spectrum::Json.configure(Rails.root)
        Spectrum::Policy::GetThis::load_config(File.join(Rails.root, 'config', 'get_this.yml'))
        config_data = YAML.load_file(File.join(Rails.root, 'config', 'aleph.yml'))
        Spectrum::Request::PlaceHold.configure do |config|
          config.lib = config_data['bib_library']
          config.adm = config_data['adm_library']
        end
        Exlibris::Aleph.configure do |config|
          config.base_url = config_data['base_url']
          config.rest_url = config_data['rest_url']
          config.adms = [config_data['adm_library']]
        end

        Spectrum::FloorLocation.configure(File.join(Rails.root, 'config', 'floor_locations.json'))
      end
    end
  end
end
