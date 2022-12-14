class SetDefaultsToBooleanFields < ActiveRecord::Migration[6.1]
  def change
    ApiSubmitterRequest.where(approved: nil).update_all(approved: false)
    ArchivedTokenUrl.where(valid_forever: nil).update_all(valid_forever: false)
    ArchivedTokenUrl.where(documents_notification: nil).update_all(documents_notification: false)
    TokenUrl.where(valid_forever: nil).update_all(valid_forever: false)
    TokenUrl.where(documents_notification: nil).update_all(documents_notification: false)
    Entity.where(full_notice_only_researchers: nil).update_all(full_notice_only_researchers: false)
    FileUpload.where(pdf_requested: nil).update_all(pdf_requested: false)
    FileUpload.where(pdf_request_fulfilled: nil).update_all(pdf_request_fulfilled: false)
    Notice.where(review_required: nil).update_all(review_required: false)
    Notice.where(spam: nil).update_all(spam: false)
    Notice.where(hidden: nil).update_all(hidden: false)
    Notice.where(webform: nil).update_all(webform: false)
    RiskTriggerCondition.where(negated: nil).update_all(negated: false)
    User.where(allow_generate_permanent_tokens_researchers_only_notices: nil).update_all(allow_generate_permanent_tokens_researchers_only_notices: false)

    change_column :api_submitter_requests, :approved, :boolean, null: false, default: false
    change_column :archived_token_urls, :valid_forever, :boolean, null: false, default: false
    change_column :archived_token_urls, :documents_notification, :boolean, null: false, default: false
    change_column :token_urls, :valid_forever, :boolean, null: false, default: false
    change_column :token_urls, :documents_notification, :boolean, null: false, default: false
    change_column :entities, :full_notice_only_researchers, :boolean, null: false, default: false
    change_column :file_uploads, :pdf_requested, :boolean, null: false, default: false
    change_column :file_uploads, :pdf_request_fulfilled, :boolean, null: false, default: false
    change_column :notices, :review_required, :boolean, null: false, default: false
    change_column :notices, :spam, :boolean, null: false, default: false
    change_column :notices, :hidden, :boolean, null: false, default: false
    change_column :notices, :webform, :boolean, null: false, default: false
    change_column :risk_trigger_conditions, :negated, :boolean, null: false, default: false
    change_column :users, :allow_generate_permanent_tokens_researchers_only_notices, :boolean, null: false, default: false
    change_column :media_mentions, :published, :boolean, null: false, default: true
  end
end
