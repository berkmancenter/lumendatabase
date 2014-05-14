require 'rails_admin/config/actions/redact_queue'
require 'rails_admin/config/actions/redact_notice'

RailsAdmin.config do |config|

  config.main_app_name = ['Chilling Effects', 'Admin']

  config.current_user_method { current_user }

  config.authorize_with :cancan

  config.audit_with :history, 'User'
  config.audit_with :history, 'Role'
  config.audit_with :history, 'Notice'

  config.actions do
    dashboard do
      statistics false
    end

    # collection-wide actions
    index
    new
    export
    history_index
    bulk_delete

    # member actions
    show
    edit
    delete
    history_show
    show_in_app

    init_actions!

    redact_queue
    redact_notice
  end

  ['Notice', Notice::TYPES].flatten.each do |notice_type|
    config.audit_with :history, notice_type

    config.model notice_type do
      label { abstract_model.model.label }
      list do
        field :id
        field :title
        field(:date_sent)     { label 'Sent' }
        field(:date_received) { label 'Received' }
        field(:created_at)    { label 'Submitted' }
        field(:original_notice_id) { label 'Legacy NoticeID' }
        field :source
        field :review_required
        field :body
        field :entities
        field :topics
        field :works
      end
      edit do
        configure(:topic_assignments) { hide }
        configure(:topic_relevant_questions) { hide }

        configure(:related_blog_entries) { hide }

        configure(:blog_topic_assignments) { hide }
        configure(:entities) { hide }
        configure(:infringing_urls) { hide }
        configure(:copyrighted_urls) { hide }

        configure :review_required do
          visible do
            ability = Ability.new(bindings[:view]._current_user)
            ability.can? :publish, Notice
          end
        end

        configure :rescinded do
          visible do
            ability = Ability.new(bindings[:view]._current_user)
            ability.can? :rescind, Notice
          end
        end
      end
    end
  end

  config.model 'Topic' do
    list do
      field :id
      field :name
    end
    edit do
      configure(:ancestry) { hide }

      configure(:notices) { hide }
      configure(:topic_assignments) { hide }

      configure(:blog_entries) { hide }
      configure(:blog_entry_topic_assignments) { hide }
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
