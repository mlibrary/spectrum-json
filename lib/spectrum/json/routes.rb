Spectrum::Json::Engine.routes.draw do
  match '',
    to: 'json#index',
    via: [:get, :post, :options]

  Spectrum::Json.routes(self)

  get 'janbo'     => 'janbo#index'
  get 'janbo/:id' => 'janbo#show'
end
