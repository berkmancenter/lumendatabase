Chill::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :notices do
    resources :search, only: [:index]
  end

  resources :notices, only: [:show, :new, :create]

  namespace :entities do
    resources :search, only: [:index]
  end

  get '/n/:id', to: 'notices#show'
  get '/N/:id', to: 'notices#show'

  resources :categories, only: [:show]

  scope format: true, constraints: { format: :json } do
    resources :categories, only: [:index]
  end

  resources :blog_entries, only: [:index, :show]

  match :faceted_search, controller: 'notices/search', action: 'index'

  # N.B. no constraints on categories, that would require a db call
  match '/:recipient_name(/:categories)' => 'notices/search#index',
    constraints: { recipient_name: /Twitter|Google/i }

  root to: 'home#index'
end
