require 'rails'

module Spectrum
  module Json
    class Railtie < Rails::Railtie
      initializer 'spectrum-json.initialize' do
         Spectrum::Json.configure(Rails.root)
         Spectrum::Policy::GetThis::load_config(File.join(Rails.root, 'config', 'get_this.yml'))
      end
    end
  end
end
