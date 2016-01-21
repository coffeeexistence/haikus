Rails.application.routes.draw do
  get "sign_up" => "users#new", :as => "sign_up"
  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"

  root :to => "main#index"
  resources :haikus do
    resources :lines, only: [:index, :new, :create, :update, :show, :destroy]
  end
  resources :main, only: [:index]
  resources :users, only: [:new, :create, :destroy]
  resources :sessions, only: [:create, :new, :destroy]
end
