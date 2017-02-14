require 'rails'

module Spectrum
  module Json
    class Railtie < Rails::Railtie
      initializer 'spectrum-json.initialize' do
         Spectrum::Json.configure(Rails.root)
      end
    end
  end
end
