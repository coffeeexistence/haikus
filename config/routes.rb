Rails.application.routes.draw do
  get "sign_up" => "users#new", as: "sign_up"
  get "log_in" => "sessions#new", as: "log_in"
  post "log_in" => "sessions#create"
  get "log_out" => "sessions#destroy", as: "log_out"
  get "profile" => "users#edit", as: "profile"
  get "forgot_password" => "users#forgot_password", as: "forgot_password"
  get "new_password/:uuid" => "users#new_password", as: "new_password"
  patch "enter_email" => "users#enter_email", as: "enter_email"
  post 'add_friend' => "users#add_friend"
  patch "update_password/:id" => "users#update_password", as: "update_password"

  root :to => "main#index"
  resources :haikus do
    resources :lines, only: [:index, :new, :create, :update, :show, :destroy]
  end
  resources :main, only: [:index]
  resources :users, except: [:index, :show, :edit]
  resources :sessions, only: [:create, :new, :destroy]
end
