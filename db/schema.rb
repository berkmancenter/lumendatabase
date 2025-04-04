# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_04_214041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_submitter_requests", force: :cascade do |t|
    t.string "email", null: false
    t.string "submissions_forward_email", null: false
    t.text "description", default: ""
    t.string "entity_name", null: false
    t.string "entity_kind", default: "individual", null: false
    t.string "entity_address_line_1", default: ""
    t.string "entity_address_line_2", default: ""
    t.string "entity_state", default: ""
    t.string "entity_country_code", default: ""
    t.string "entity_phone", default: ""
    t.string "entity_url", default: ""
    t.string "entity_email", default: ""
    t.string "entity_city", default: ""
    t.string "entity_zip", default: ""
    t.text "admin_notes", default: ""
    t.bigint "user_id"
    t.boolean "approved"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_api_submitter_requests_on_user_id"
  end

  create_table "archived_token_urls", force: :cascade do |t|
    t.string "email"
    t.string "token"
    t.bigint "notice_id"
    t.bigint "user_id"
    t.datetime "expiration_date", precision: nil
    t.boolean "valid_forever", default: false, null: false
    t.boolean "documents_notification", default: false, null: false
    t.integer "views", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "ip"
    t.index ["documents_notification"], name: "index_archived_token_urls_on_documents_notification"
    t.index ["email"], name: "index_archived_token_urls_on_email"
    t.index ["notice_id"], name: "index_archived_token_urls_on_notice_id"
    t.index ["token"], name: "index_archived_token_urls_on_token"
    t.index ["user_id"], name: "index_archived_token_urls_on_user_id"
  end

  create_table "blocked_token_url_domains", force: :cascade do |t|
    t.string "name"
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_blocked_token_url_domains_on_name"
  end

  create_table "blocked_token_url_ips", force: :cascade do |t|
    t.string "address"
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_blocked_token_url_ips_on_address"
  end

  create_table "comfy_cms_categories", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "label", null: false
    t.string "categorized_type", null: false
    t.index ["site_id", "categorized_type", "label"], name: "index_cms_categories_on_site_id_and_cat_type_and_label", unique: true
  end

  create_table "comfy_cms_categorizations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "categorized_type", null: false
    t.integer "categorized_id", null: false
    t.index ["category_id", "categorized_type", "categorized_id"], name: "index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id", unique: true
  end

  create_table "comfy_cms_files", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "label", default: "", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["site_id", "position"], name: "index_comfy_cms_files_on_site_id_and_position"
  end

  create_table "comfy_cms_fragments", force: :cascade do |t|
    t.string "record_type"
    t.bigint "record_id"
    t.string "identifier", null: false
    t.string "tag", default: "text", null: false
    t.text "content"
    t.boolean "boolean", default: false, null: false
    t.datetime "datetime", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["boolean"], name: "index_comfy_cms_fragments_on_boolean"
    t.index ["datetime"], name: "index_comfy_cms_fragments_on_datetime"
    t.index ["identifier"], name: "index_comfy_cms_fragments_on_identifier"
    t.index ["record_type", "record_id"], name: "index_comfy_cms_fragments_on_record_type_and_record_id"
  end

  create_table "comfy_cms_layouts", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "parent_id"
    t.string "app_layout"
    t.string "label", null: false
    t.string "identifier", null: false
    t.text "content"
    t.text "css"
    t.text "js"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["parent_id", "position"], name: "index_comfy_cms_layouts_on_parent_id_and_position"
    t.index ["site_id", "identifier"], name: "index_comfy_cms_layouts_on_site_id_and_identifier", unique: true
  end

  create_table "comfy_cms_pages", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "layout_id"
    t.integer "parent_id"
    t.integer "target_page_id"
    t.string "label", null: false
    t.string "slug"
    t.string "full_path", null: false
    t.text "content_cache"
    t.integer "position", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.boolean "is_published", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["is_published"], name: "index_comfy_cms_pages_on_is_published"
    t.index ["parent_id", "position"], name: "index_comfy_cms_pages_on_parent_id_and_position"
    t.index ["site_id", "full_path"], name: "index_comfy_cms_pages_on_site_id_and_full_path"
  end

  create_table "comfy_cms_revisions", force: :cascade do |t|
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.index ["record_type", "record_id", "created_at"], name: "index_cms_revisions_on_rtype_and_rid_and_created_at"
  end

  create_table "comfy_cms_sites", force: :cascade do |t|
    t.string "label", null: false
    t.string "identifier", null: false
    t.string "hostname", null: false
    t.string "path"
    t.string "locale", default: "en", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hostname"], name: "index_comfy_cms_sites_on_hostname"
  end

  create_table "comfy_cms_snippets", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "label", null: false
    t.string "identifier", null: false
    t.text "content"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["site_id", "identifier"], name: "index_comfy_cms_snippets_on_site_id_and_identifier", unique: true
    t.index ["site_id", "position"], name: "index_comfy_cms_snippets_on_site_id_and_position"
  end

  create_table "comfy_cms_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.integer "page_id", null: false
    t.integer "layout_id"
    t.string "label", null: false
    t.text "content_cache"
    t.boolean "is_published", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["is_published"], name: "index_comfy_cms_translations_on_is_published"
    t.index ["locale"], name: "index_comfy_cms_translations_on_locale"
    t.index ["page_id"], name: "index_comfy_cms_translations_on_page_id"
  end

  create_table "content_filters", force: :cascade do |t|
    t.string "name"
    t.string "query"
    t.text "notes"
    t.jsonb "actions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "document_notification_emails", force: :cascade do |t|
    t.bigint "notice_id", null: false
    t.string "email_address", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 1
    t.index ["notice_id"], name: "index_document_notification_emails_on_notice_id"
  end

  create_table "documents_update_notification_notices", id: :serial, force: :cascade do |t|
    t.integer "notice_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "status", default: 0
  end

  create_table "entities", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "kind", default: "individual", null: false
    t.string "address_line_1", default: ""
    t.string "address_line_2", default: ""
    t.string "state", default: ""
    t.string "country_code", default: ""
    t.string "phone", default: ""
    t.string "email", default: ""
    t.string "url", default: ""
    t.string "ancestry"
    t.string "city", default: ""
    t.string "zip", default: ""
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name_original"
    t.boolean "full_notice_only_researchers", default: false, null: false
    t.string "address_line_1_original"
    t.string "address_line_2_original"
    t.string "city_original"
    t.string "state_original"
    t.string "country_code_original"
    t.string "zip_original"
    t.string "url_original"
    t.text "name_description"
    t.index ["address_line_1"], name: "index_entities_on_address_line_1"
    t.index ["ancestry"], name: "index_entities_on_ancestry"
    t.index ["city"], name: "index_entities_on_city"
    t.index ["country_code"], name: "index_entities_on_country_code"
    t.index ["email"], name: "index_entities_on_email"
    t.index ["name"], name: "index_entities_on_name"
    t.index ["phone"], name: "index_entities_on_phone"
    t.index ["state"], name: "index_entities_on_state"
    t.index ["updated_at"], name: "index_entities_on_updated_at"
    t.index ["user_id"], name: "index_entities_on_user_id"
    t.index ["zip"], name: "index_entities_on_zip"
  end

  create_table "entities_full_notice_only_researchers_users", force: :cascade do |t|
    t.bigint "entity_id"
    t.bigint "user_id"
    t.index ["entity_id"], name: "index_entities_full_notice_only_researchers_users_on_entity_id"
  end

  create_table "entity_notice_roles", id: :serial, force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "notice_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entity_notice_roles_on_entity_id"
    t.index ["notice_id"], name: "index_entity_notice_roles_on_notice_id"
  end

  create_table "file_uploads", id: :serial, force: :cascade do |t|
    t.integer "notice_id"
    t.string "kind"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.string "file_content_type"
    t.datetime "file_updated_at", precision: nil
    t.boolean "pdf_requested", default: false, null: false
    t.boolean "pdf_request_fulfilled", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notice_id"], name: "index_file_uploads_on_notice_id"
  end

  create_table "lumen_settings", force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_mentions", force: :cascade do |t|
    t.string "title", limit: 1000
    t.text "description"
    t.string "source", limit: 1000
    t.string "link_to_source", limit: 1000
    t.string "scale_of_mention", limit: 1000, null: false
    t.date "date"
    t.string "document_type", limit: 100
    t.text "comments"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "author"
  end

  create_table "notice_import_errors", id: :serial, force: :cascade do |t|
    t.integer "original_notice_id"
    t.string "file_list", limit: 2048
    t.string "message", limit: 16384
    t.string "stacktrace", limit: 2048
    t.string "import_set_name", limit: 1024
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "notice_update_calls", force: :cascade do |t|
    t.integer "caller_id"
    t.string "caller_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notices", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "body"
    t.datetime "date_received", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "source"
    t.string "subject"
    t.boolean "review_required", default: false, null: false
    t.text "body_original"
    t.datetime "date_sent", precision: nil
    t.integer "reviewer_id"
    t.string "language"
    t.boolean "rescinded", default: false, null: false
    t.string "action_taken"
    t.string "type"
    t.integer "original_notice_id"
    t.boolean "spam", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.string "request_type"
    t.integer "submission_id"
    t.string "mark_registration_number"
    t.boolean "published", default: true, null: false
    t.integer "url_count"
    t.boolean "webform", default: false, null: false
    t.text "notes"
    t.integer "counternotice_for_id"
    t.integer "counternotice_for_sid"
    t.integer "views_overall", default: 0
    t.integer "views_by_notice_viewer", default: 0
    t.text "local_jurisdiction_laws"
    t.jsonb "works_json", default: [], null: false
    t.integer "case_id_number"
    t.jsonb "tag_list", default: []
    t.jsonb "jurisdiction_list", default: []
    t.jsonb "regulation_list", default: []
    t.jsonb "customizations", default: {}
    t.index ["created_at"], name: "index_notices_on_created_at"
    t.index ["original_notice_id"], name: "index_notices_on_original_notice_id"
    t.index ["published"], name: "index_notices_on_published"
    t.index ["reviewer_id"], name: "index_notices_on_reviewer_id"
    t.index ["submission_id"], name: "index_notices_on_submission_id"
    t.index ["type"], name: "index_notices_on_type"
    t.index ["updated_at"], name: "index_notices_on_updated_at"
    t.check_constraint "validate_works_json(works_json)", name: "notices_works_json_check"
  end

  create_table "notices_relevant_questions", id: :serial, force: :cascade do |t|
    t.integer "notice_id"
    t.integer "relevant_question_id"
    t.index ["notice_id"], name: "index_notices_relevant_questions_on_notice_id"
    t.index ["relevant_question_id"], name: "index_notices_relevant_questions_on_relevant_question_id"
  end

  create_table "rails_admin_histories", id: :serial, force: :cascade do |t|
    t.text "message"
    t.string "username"
    t.integer "item"
    t.string "table"
    t.integer "month", limit: 2
    t.bigint "year"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["item"], name: "index_rails_admin_histories_on_item"
    t.index ["month"], name: "index_rails_admin_histories_on_month"
    t.index ["table"], name: "index_rails_admin_histories_on_table"
    t.index ["year"], name: "index_rails_admin_histories_on_year"
  end

  create_table "relevant_questions", id: :serial, force: :cascade do |t|
    t.text "question", null: false
    t.text "answer", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relevant_questions_topics", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "relevant_question_id"
    t.index ["relevant_question_id"], name: "index_relevant_questions_topics_on_relevant_question_id"
    t.index ["topic_id"], name: "index_relevant_questions_topics_on_topic_id"
  end

  create_table "risk_trigger_conditions", id: :serial, force: :cascade do |t|
    t.string "field", null: false
    t.string "value", null: false
    t.boolean "negated", default: false, null: false
    t.string "matching_type"
    t.integer "risk_trigger_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["risk_trigger_id"], name: "index_risk_trigger_conditions_on_risk_trigger_id"
  end

  create_table "risk_triggers", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "matching_type", null: false
    t.string "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "special_domains", force: :cascade do |t|
    t.string "domain_name"
    t.text "notes"
    t.jsonb "why_special"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "token_urls", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "token"
    t.integer "notice_id", null: false
    t.integer "user_id"
    t.datetime "expiration_date", precision: nil
    t.boolean "valid_forever", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "documents_notification", default: false, null: false
    t.integer "views", default: 0
    t.string "ip"
    t.index ["documents_notification"], name: "index_token_urls_on_documents_notification"
    t.index ["email"], name: "index_token_urls_on_email"
    t.index ["notice_id"], name: "index_token_urls_on_notice_id"
    t.index ["token"], name: "index_token_urls_on_token"
    t.index ["user_id"], name: "index_token_urls_on_user_id"
  end

  create_table "topic_assignments", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "notice_id"
    t.index ["notice_id"], name: "index_topics_notices_on_notice_id"
    t.index ["topic_id"], name: "index_topics_notices_on_topic_id"
  end

  create_table "topic_managers", id: :serial, force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "topic_managers_topics", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "topic_manager_id"
    t.index ["topic_id"], name: "index_topic_managers_topics_on_topic_id"
    t.index ["topic_manager_id"], name: "index_topic_managers_topics_on_topic_manager_id"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description", default: ""
    t.string "ancestry"
    t.integer "original_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ancestry"], name: "index_topics_on_ancestry"
  end

  create_table "translations", force: :cascade do |t|
    t.string "key"
    t.text "notes", default: ""
    t.text "body", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.string "authentication_token"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "publication_delay", default: 0, null: false
    t.boolean "can_generate_permanent_notice_token_urls", default: false, null: false
    t.integer "full_notice_views_limit", default: 1
    t.integer "viewed_notices", default: 0, null: false
    t.datetime "full_notice_time_limit", precision: nil
    t.boolean "limit_notice_api_response", default: false, null: false
    t.boolean "allow_generate_permanent_tokens_researchers_only_notices", default: false, null: false
    t.string "widget_submissions_forward_email"
    t.string "widget_public_key"
    t.text "notes"
    t.integer "entity_id"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["entity_id"], name: "index_users_on_entity_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["widget_public_key"], name: "index_users_on_widget_public_key", unique: true
  end

  create_table "youtube_import_errors", force: :cascade do |t|
    t.integer "original_notice_id"
    t.text "message"
    t.string "filename", limit: 1024
    t.text "stacktrace"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "youtube_import_file_locations", force: :cascade do |t|
    t.bigint "file_upload_id"
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_upload_id"], name: "index_youtube_import_file_locations_on_file_upload_id"
  end

  create_table "yt_imports", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
