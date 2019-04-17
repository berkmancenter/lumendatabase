Chill::Application.routes.draw do
  get 'file_uploads/files/:id/*file_path', to: 'files#show'

  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :notices do
    resources :search, only: [:index]
  end

  resources :notices, only: %i[show new create] do
    collection do
      get :url_input
    end
    member do
      put :request_pdf
      get :request_access, to: 'token_urls#new'
      post :generate_permanent_full_url, to: 'token_urls#generate_permanent'
    end
  end

  namespace :entities do
    resources :search, only: [:index]
  end

  get '/n/:id', to: 'notices#show'
  get '/N/:id', to: 'notices#show'

  get '/submission_id/:id', to: 'submission_ids#show'
  get '/original_notice_id/:id', to: 'original_notice_ids#show'

  get '/original_news_id/:id', to: 'original_news_ids#show'

  resources :topics, only: [:show]

  scope format: true, constraints: { format: :json } do
    resources :topics, only: [:index]
  end

  resources :blog_entries, only: %i[index show archive]
  get 'blog_feed', to: 'blog_entries#feed'
  get 'notices_feed', to: 'notices#feed'
  get 'blog_archive', to: 'blog_entries#archive'

  match :faceted_search,
        controller: 'notices/search',
        action: 'index', via: %i[get post]

  get '/twitter/international',
      to: 'notices/search#index',
      defaults: { topics: 'international, court orders, law enforcement requests, government requests',
                  recipient_name: 'twitter' }

  # N.B. no constraints on topics, that would require a db call
  match '/:recipient_name(/:topics)' => 'notices/search#index',
        constraints: { recipient_name: /Twitter|Google/i },
        via: %i[get post]

  resources :token_urls, only: :create do
    member do
      get :disable_documents_notification
    end
  end

  root to: 'home#index'
end
