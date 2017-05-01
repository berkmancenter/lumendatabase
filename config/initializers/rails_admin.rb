require 'rails_admin/config/actions/redact_queue'
require 'rails_admin/config/actions/redact_notice'
require 'rails_admin/config/actions/pdf_requests'

RailsAdmin.config do |config|
  config.parent_controller = '::ApplicationController'

  config.main_app_name = ['Lumen Database', 'Admin']

  config.current_user_method { current_user }

  config.authorize_with :cancan

  config.audit_with :history, 'User'
  config.audit_with :history, 'Role'
  config.audit_with :history, 'Notice'

  # config.attr_accessible_role { :admin }

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

    pdf_requests
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
        field :published
        field :time_to_publish
        field :body
        field :entities
        field :topics
        field :works
        field :url_count
        field :action_taken
        field :reviewer_id
        field :language
        field :rescinded
        field :type
        field :spam
        field :hidden
        field :request_type
        field :webform
      end

      show do
        configure(:infringing_urls) { hide }
        configure(:copyrighted_urls) { hide }
      end

      edit do
        configure :action_taken, :enum do
          enum do
            ['Yes', 'No', 'Partial', 'Unspecified']
          end
          default_value 'Unspecified'
        end

        configure(:type) do
          hide
        end
        configure :reset_type, :enum do
          label "Type"
          required true
        end
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
      field :parent do
        formatted_value do
          parent = bindings[:object].parent
          parent && "#{parent.name} - ##{parent.id}"
        end
      end
    end
    edit do
      configure(:notices) { hide }
      configure(:topic_assignments) { hide }

      configure(:blog_entries) { hide }
      configure(:blog_entry_topic_assignments) { hide }
      configure :parent_id, :enum do
        enum_method do
          :parent_enum
        end
      end
    end
  end

  config.model 'EntityNoticeRole' do
    edit do
      configure(:notice) { hide }
    end
  end

  config.model 'Entity' do
    list do
      configure(:notices) { hide }
      configure(:entity_notice_roles) { hide }
      configure :parent do
        formatted_value do
          parent = bindings[:object].parent
          parent && "#{parent.name} - ##{parent.id}"
        end
      end
    end
    edit do
      configure :kind, :enum do
        enum do
          ['individual', 'organization']
        end
        default_value 'organization'
      end
      configure(:notices) { hide }
      configure(:entity_notice_roles) { hide }
      configure(:ancestry) { hide }
      # Unfortunately, there are too many entities to make parents editable
      # via default rails_admin functionality.
      # configure :parent_id, :enum do
      #   enum_method do
      #     :parent_enum
      #   end
      # end
    end
  end

  config.model 'RelevantQuestion' do
    object_label_method { :question }
  end

  config.model 'Work' do
    object_label_method { :custom_work_label }
    
    edit do
      configure(:notices) { hide }
    end

    list do
      configure(:copyrighted_urls) { hide }
      configure(:infringing_urls) { hide }
    end
    nested do
      configure(:infringing_urls) { hide }
      configure(:copyrighted_urls) { hide }
    end

  end

  config.model 'InfringingUrl' do
    object_label_method { :url }
  end

  config.model 'FileUpload' do
    edit do
      configure :kind, :enum do
        enum do
          ['original', 'supporting']
        end
      end
    end
  end

  config.model 'ReindexRun' do

  end

  def custom_work_label
    %Q|#{self.id}: #{self.description && self.description[0,30]}...|
  end

  config.model 'User' do
    object_label_method { :email }
    edit do
      configure :entity do
        nested_form false
      end
    end
  end
end
