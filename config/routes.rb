Rails.application.routes.draw do
  get '/ping' => 'main#ping'
  resources :haikus, constraints: {format: :json} do
    resources :lines, only: [:index, :create, :update, :show, :destroy], constraints: {format: :json}
  root :to => "main#index"
  end
  resources :users, only: [:create, :destroy]
  resources :api_keys, only: :create
  resources :main, only: [:index]
end
