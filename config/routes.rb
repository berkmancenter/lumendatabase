Rails.application.routes.draw do
  get 'file_uploads/files/:id/*file_path', to: 'files#show'

  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :notices do
    resources :search, only: %i[index] do
      collection do
        get :facet
      end
    end
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

  resources :submitter_widget_notices, only: %i[new create]

  namespace :entities do
    resources :search, only: [:index]
  end

  get '/n/:id', to: 'notices#show'
  get '/N/:id', to: 'notices#show'

  # URLs conforming to old patterns, like /notice.cgi?sID=X, are rewritten by
  # the proxies before they get here.
  get '/submission_id/:id', to: 'submission_ids#show', as: 'notice_by_sid'
  get '/original_notice_id/:id', to: 'original_notice_ids#show'

  resources :topics, only: [:show]

  scope format: true, constraints: { format: :json } do
    resources :topics, only: [:index]
  end

  get 'notices_feed', to: 'notices#feed'

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

  get 'blog_feed', to: 'blog_feed#index'

  namespace :media_mentions do
    resources :search, only: %i[index] do
      collection do
        get :facet
      end
    end
  end

  resources :media_mentions, only: :show

  resources :api_submitter_requests

  resources :captcha_gateway, only: :index

  resources :status, only: :index

  root to: 'home#index', via: :get
  match '/', to: 'application#routing_error', via: ActionDispatch::Routing::HTTP_METHODS - [:get]

  comfy_route :cms_admin, path: '/cms_admin'

  get '/(*cms_path)(.:format)', to: 'comfy/cms/content#show'

  match '*unmatched', to: 'application#resource_not_found', via: :all
end
