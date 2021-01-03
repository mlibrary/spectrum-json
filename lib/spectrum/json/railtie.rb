# frozen_string_literal: true

require 'rails'
require 'exlibris-aleph'

module Spectrum
  module Json
    class Railtie < Rails::Railtie
      initializer 'spectrum-json.initialize' do
        Spectrum::Json.configure(Rails.root, Rails.configuration.relative_url_root)

        if File.exist?(get_this_file = File.join(Rails.root, 'config', 'get_this.yml'))
          Spectrum::Policy::GetThis.load_config(get_this_file)
        end

        config_data = if File.exist?(aleph_config_file = File.join(Rails.root, 'config', 'aleph.yml'))
          YAML.load(ERB.new(File.read(aleph_config_file)).result)
        else
          {}
        end

        Spectrum::Request::PlaceHold.configure do |config|
          config.lib = config_data['bib_library']
          config.adm = config_data['adm_library']
        end
        Exlibris::Aleph.configure do |config|
          config.base_url = config_data['base_url']
          config.rest_url = config_data['rest_url']
          config.adms = [config_data['adm_library']]
        end

        if File.exist?(floor_locations = File.join(Rails.root, 'config', 'floor_locations.json'))
          Spectrum::FloorLocation.configure(floor_locations)
        end

        if File.exist?(specialists_file = File.join(Rails.root, 'config', 'specialists.yml'))
          Spectrum::Response::Specialists.configure(specialists_file)
        end
      end

      rake_tasks do
        load 'spectrum/json.rake'
      end
    end
  end
end
