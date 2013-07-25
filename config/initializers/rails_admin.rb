require 'rails_admin/config/actions/redact_queue'
require 'rails_admin/config/actions/redact_notice'

RailsAdmin.config do |config|

  config.main_app_name = ['Chilling Effects', 'Admin']

  config.current_user_method { current_user }

  config.authorize_with :cancan

  config.actions do
    init_actions!

    redact_queue
    redact_notice
  end

  config.model 'Notice' do
    list do
      field :id
      field :title
      field(:date_sent)     { label 'Sent' }
      field(:date_received) { label 'Received' }
      field(:created_at)    { label 'Submitted' }
      field :source
      field :review_required
      field :body
      field :entities
      field :categories
      field :works
    end
    edit do
      configure(:categorizations) { hide }
      configure(:blog_categorizations) { hide }
      configure(:category_relevant_questions) { hide }
      configure(:entities) { hide }
      configure(:infringing_urls) { hide }

      configure :review_required do
        visible do
          ability = Ability.new(bindings[:view]._current_user)
          ability.can? :publish, Notice
        end
      end
    end
  end

  config.model 'Category' do
    edit do
      configure(:ancestry) { hide }
    end
  end

  config.model 'EntityNoticeRole' do
    edit do
      configure(:notice) { hide }
    end
  end

  config.model 'Entity' do
    edit do
      configure(:notices) { hide }
      configure(:entity_notice_roles) { hide }
    end
  end

  config.model 'RelevantQuestion' do
    object_label_method { :question }
  end

  config.model 'Work' do
    object_label_method { :description }

    edit do
      configure(:notices) { hide }
    end
  end

  config.model 'InfringingUrl' do
    object_label_method { :url }
  end

end
