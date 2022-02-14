require 'rails_admin/config/actions/redact_queue'
require 'rails_admin/config/actions/redact_notice'
require 'rails_admin/config/actions/pdf_requests'
require 'rails_admin/config/actions/statistics'
require 'rails_admin/config/actions/approve_api_submitter_request'
require 'rails_admin/config/actions/reject_api_submitter_request'
require 'rails_admin/config/actions/top_notices_token_urls'
require 'rails_admin/config/fields/types/datetime_timezoned'

# Monkeypatches
RailsAdmin::Config::Fields::Types::Datetime.prepend RailsAdmin::Config::Fields::Types::DatetimeTimezoned

# Config
RailsAdmin.config do |config|
  config.parent_controller = '::ApplicationController'

  config.main_app_name = ['Lumen Database', 'Admin']

  config.current_user_method { current_user }

  config.authorize_with :cancancan

  config.audit_with :history, 'User'
  config.audit_with :history, 'Role'
  config.audit_with :history, 'Notice'

  boolean_true_icon = '<span class="label label-success">&#x2713;</span>'.html_safe
  boolean_false_icon = '<span class="label label-danger">&#x2718;</span>'.html_safe

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
    statistics
    approve_api_submitter_request
    reject_api_submitter_request
    top_notices_token_urls
  end

  ['Notice', Notice::TYPES].flatten.each do |notice_type|
    config.audit_with :history, notice_type

    config.model notice_type do
      label { abstract_model.model.label }

      list do
        # SELECT COUNT is slow when the number of instances is large; let's
        # avoid calling it for Notice and its subclasses.
        limited_pagination true

        field :id
        field :title
        field(:date_sent)     { label 'Sent' }
        field(:date_received) { label 'Received' }
        field(:created_at)    { label 'Submitted' }
        field(:original_notice_id) { label 'Legacy NoticeID' }
        field :submission_id
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
        field :views_overall
        field :views_by_notice_viewer
        field :token_urls_count
      end

      show do
        field :title
        field :type
        field :published
        field :date_received
        field :date_sent
        field :source
        field :subject
        field :review_required
        field :language
        field :rescinded
        field :spam
        field :hidden
        field :restricted_to_researchers do
          formatted_value do
            bindings[:object].restricted_to_researchers? ? boolean_true_icon : boolean_false_icon
          end
        end
        field :webform
        field :views_overall
        field :views_by_notice_viewer
        field :temporary_token_urls do
          formatted_value do
            notice_token_urls_count_links(bindings)
          end
        end
        field :permanent_token_urls do
          formatted_value do
            notice_token_urls_count_links(bindings, true)
          end
        end
        field :topics
        field :entity_notice_roles
        field :entities
        field :works
        field :file_uploads
        field :case_id_number
      end

      edit do
        # This dramatically speeds up the admin page.
        configure :works do
          nested_form false
        end

        configure :action_taken, :enum do
          enum do
            %w[Yes No Partial Unspecified]
          end
          default_value 'Unspecified'
        end

        configure(:type) do
          hide
        end

        configure :reset_type, :enum do
          label 'Type'
          required true
        end

        exclude_fields :topic_assignments,
                       :topic_relevant_questions,
                       :infringing_urls,
                       :copyrighted_urls,
                       :token_urls,
                       :entities

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

        configure(:works) do
          hide
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
      # exclude_fields :notices might be a better performance option than hide,
      # but it prevents topics with null ancestries from being saved.
      configure(:notices) { hide }
      configure(:topic_assignments) { hide }

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
      configure :entity do
        nested_form false
      end
    end
  end

  config.model 'Entity' do
    list do
      # See exclude_fields comment for Topic.
      exclude_fields :notices
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
          %w[individual organization]
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
      limited_pagination true
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

    list do
      limited_pagination true
    end
  end

  config.model 'FileUpload' do
    edit do
      configure :kind, :enum do
        enum do
          %w[original supporting]
        end
      end
    end
  end

  config.model 'ReindexRun' do
  end

  def custom_work_label
    %Q(#{self.id}: #{self.description && self.description[0,30]}...)
  end

  config.model 'User' do
    object_label_method { :email }
    edit do
      configure :entity do
        nested_form false
      end
      configure(:token_urls) { hide }

      field :email
      field :password
      field :password_confirmation
      field :notes
      field :reset_password_sent_at
      field :authentication_token
      field :widget_public_key
      field :publication_delay
      field :can_generate_permanent_notice_token_urls
      field :allow_generate_permanent_tokens_researchers_only_notices
      field :full_notice_views_limit
      field :full_notice_time_limit
      field :viewed_notices
      field :limit_notice_api_response
      field :entity
      field :roles
      field :full_notice_only_researchers_entities
      field :widget_submissions_forward_email
    end

    list do
      scopes [nil] + Role::NAMES.sort.map { |role| "#{role}s" }

      field :email
      field :entity
      field :roles
      field :created_at
      field :full_notice_time_limit
    end
  end

  config.model 'TokenUrl' do
    token_url_config
  end

  config.model 'ArchivedTokenUrl' do
    token_url_config
  end

  config.model 'RiskTriggerCondition' do
    edit do
      configure :field, :enum do
        enum do
          RiskTriggerCondition::ALLOWED_FIELDS.sort
        end
      end
      configure :matching_type, :enum do
        enum do
          RiskTriggerCondition::ALLOWED_MATCHING_TYPES
        end
      end
    end
  end

  config.model 'RiskTrigger' do
    edit do
      configure :matching_type, :enum do
        enum do
          RiskTrigger::ALLOWED_MATCHING_TYPES
        end
      end
    end
  end

  config.model 'LumenSetting' do
    edit do
      field :value
    end
  end

  config.model 'BlockedTokenUrlDomain' do
    list do
      field :name
      field :comments
      field :created_at
    end
  end

  config.model 'BlockedTokenUrlIp' do
    list do
      field :address
      field :comments
      field :created_at
    end
  end

  config.model 'MediaMention' do
    edit do
      configure :scale_of_mention, :enum do
        enum do
          LumenSetting.get('media_mentions_scale_of_mentions').split(',')
        end
      end

      field :title
      field :author
      field :description
      field :source
      field :link_to_source
      field :scale_of_mention
      field :date
      field :document_type
      field :comments
      field :published
    end
  end

  config.model 'ApiSubmitterRequest' do
    list do
      field :id
      field :email
      field :entity_name
      field :entity_url
      field :user
      field :approved
    end

    edit do
      field :email
      field :submissions_forward_email
      field :approved
      field :entity_url
      field :description
      field :admin_notes
      field :entity_name
      field :entity_kind
      field :entity_address_line_1
      field :entity_address_line_2
      field :entity_state
      field :entity_country_code
      field :entity_phone
      field :entity_url
      field :entity_email
      field :entity_city
      field :entity_zip
      field :user
    end
  end

  # Hide unused models from the admin
  # == START ============================================================
  config.model 'ReindexRun' do
    visible false
  end
  config.model 'NoticeImportError' do
    visible false
  end
  config.model 'DocumentsUpdateNotificationNotice' do
    visible false
  end
  config.model 'YoutubeImportError' do
    visible false
  end
  config.model 'YtImport' do
    visible false
  end
  config.model 'YoutubeImportFileLocation' do
    visible false
  end
  config.model 'NoticeUpdateCall' do
    visible false
  end
  config.model 'ActiveStorage::Blob' do
    visible false
  end
  config.model 'ActiveStorage::Attachment' do
    visible false
  end
  config.model 'ActiveStorage::VariantRecord' do
    visible false
  end
  config.model 'Comfy::Cms::Categorization' do
    visible false
  end
  config.model 'Comfy::Cms::Category' do
    visible false
  end
  config.model 'Comfy::Cms::File' do
    visible false
  end
  config.model 'Comfy::Cms::Fragment' do
    visible false
  end
  config.model 'Comfy::Cms::Layout' do
    visible false
  end
  config.model 'Comfy::Cms::Page' do
    visible false
  end
  config.model 'Comfy::Cms::Revision' do
    visible false
  end
  config.model 'Comfy::Cms::Site' do
    visible false
  end
  config.model 'Comfy::Cms::Snippet' do
    visible false
  end
  config.model 'Comfy::Cms::Translation' do
    visible false
  end
  # == END ============================================================

  def notice_token_urls_count_links(bindings, perm = false)
    bindings[:object].token_urls.where(valid_forever: perm).count
  end

  def token_url_config
    list do
      field :email
      field :user
      field :notice
      field :expiration_date
      field(:valid_forever) { label 'Permenent' }
      field :views
      field :created_at
      field :ip
    end

    edit do
      field :email do
        required false
      end
      field :user
      field :notice do
        required true
      end
      field :expiration_date
      field(:valid_forever) { label 'Permenent' }
      field :documents_notification
    end
  end
end
