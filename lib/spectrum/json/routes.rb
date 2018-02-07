Spectrum::Json::Engine.routes.draw do
  match '',
    to: 'json#index',
    via: [:get, :post, :options]

  Spectrum::Json.routes(self)
end
