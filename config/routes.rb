Chill::Application.routes.draw do
  namespace :api do
    resources :submissions, only: [:create]
  end

  resources :notices, only: [:show]
end
