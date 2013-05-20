Chill::Application.routes.draw do
  namespace :api do
    resource :submissions, only: [:create]
  end
end
