Chill::Application.routes.draw do
  resources :notices, only: [:show]

  resources :submissions, only: [:new, :create]

  root to: 'home#index'
end
