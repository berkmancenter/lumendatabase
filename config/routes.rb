Chill::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  resources :notices, only: [:show]

  resources :submissions, only: [:new, :create]

  root to: 'home#index'
end
