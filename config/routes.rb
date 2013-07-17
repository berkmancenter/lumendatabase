Chill::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  resources :notices, only: [:show, :new, :create]

  get '/n/:id', to: 'notices#show'
  get '/N/:id', to: 'notices#show'

  resources :categories, only: [:show]

  scope format: true, constraints: { format: :json } do
    resources :categories, only: [:index]
  end

  resources :blog_entries, only: [:index, :show]

  resource :search, only: [:show]

  resource :facetted_search, only: [:show], controller: :searches

  root to: 'home#index'
end
