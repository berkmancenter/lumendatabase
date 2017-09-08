# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170908160728) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blog_entries", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "author",                                        null: false
    t.string   "title",                                         null: false
    t.text     "abstract"
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "original_news_id"
    t.string   "url",              limit: 1024
    t.boolean  "archive",                       default: false
  end

  create_table "blog_entry_topic_assignments", force: :cascade do |t|
    t.integer "blog_entry_id"
    t.integer "topic_id"
  end

  add_index "blog_entry_topic_assignments", ["blog_entry_id"], name: "index_blog_entry_topic_assignments_on_blog_entry_id", using: :btree
  add_index "blog_entry_topic_assignments", ["topic_id"], name: "index_blog_entry_topic_assignments_on_topic_id", using: :btree

  create_table "copyrighted_urls", force: :cascade do |t|
    t.string   "url_original", limit: 8192, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",          limit: 8192
  end

  add_index "copyrighted_urls", ["url_original"], name: "index_copyrighted_urls_on_url_original", unique: true, using: :btree

  create_table "copyrighted_urls_works", id: false, force: :cascade do |t|
    t.integer "copyrighted_url_id", null: false
    t.integer "work_id",            null: false
  end

  add_index "copyrighted_urls_works", ["copyrighted_url_id"], name: "index_copyrighted_urls_works_on_copyrighted_url_id", using: :btree
  add_index "copyrighted_urls_works", ["work_id"], name: "index_copyrighted_urls_works_on_work_id", using: :btree

  create_table "entities", force: :cascade do |t|
    t.string   "name",                                  null: false
    t.string   "kind",           default: "individual", null: false
    t.string   "address_line_1", default: ""
    t.string   "address_line_2", default: ""
    t.string   "state",          default: ""
    t.string   "country_code",   default: ""
    t.string   "phone",          default: ""
    t.string   "email",          default: ""
    t.string   "url",            default: ""
    t.string   "ancestry"
    t.string   "city",           default: ""
    t.string   "zip",            default: ""
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_original"
  end

  add_index "entities", ["address_line_1"], name: "index_entities_on_address_line_1", using: :btree
  add_index "entities", ["ancestry"], name: "index_entities_on_ancestry", using: :btree
  add_index "entities", ["city"], name: "index_entities_on_city", using: :btree
  add_index "entities", ["country_code"], name: "index_entities_on_country_code", using: :btree
  add_index "entities", ["email"], name: "index_entities_on_email", using: :btree
  add_index "entities", ["name", "address_line_1", "city", "state", "zip", "country_code", "phone", "email"], name: "unique_entity_attribute_index", unique: true, using: :btree
  add_index "entities", ["name"], name: "index_entities_on_name", using: :btree
  add_index "entities", ["phone"], name: "index_entities_on_phone", using: :btree
  add_index "entities", ["state"], name: "index_entities_on_state", using: :btree
  add_index "entities", ["updated_at"], name: "index_entities_on_updated_at", using: :btree
  add_index "entities", ["user_id"], name: "index_entities_on_user_id", using: :btree
  add_index "entities", ["zip"], name: "index_entities_on_zip", using: :btree

  create_table "entity_notice_roles", force: :cascade do |t|
    t.integer  "entity_id",  null: false
    t.integer  "notice_id",  null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entity_notice_roles", ["entity_id"], name: "index_entity_notice_roles_on_entity_id", using: :btree
  add_index "entity_notice_roles", ["notice_id"], name: "index_entity_notice_roles_on_notice_id", using: :btree

  create_table "file_uploads", force: :cascade do |t|
    t.integer  "notice_id"
    t.string   "kind"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.boolean  "pdf_requested"
    t.boolean  "pdf_request_fulfilled", default: false
  end

  add_index "file_uploads", ["notice_id"], name: "index_file_uploads_on_notice_id", using: :btree

  create_table "infringing_urls", id: :bigserial, force: :cascade do |t|
    t.string   "url_original", limit: 8192, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",          limit: 8192
  end

  add_index "infringing_urls", ["url_original"], name: "index_infringing_urls_on_url_original", unique: true, using: :btree

  create_table "infringing_urls_works", id: false, force: :cascade do |t|
    t.integer "infringing_url_id", limit: 8, null: false
    t.integer "work_id",                     null: false
  end

  add_index "infringing_urls_works", ["infringing_url_id"], name: "index_infringing_urls_works_on_infringing_url_id", using: :btree
  add_index "infringing_urls_works", ["work_id"], name: "index_infringing_urls_works_on_work_id", using: :btree

  create_table "notice_import_errors", force: :cascade do |t|
    t.integer  "original_notice_id"
    t.string   "file_list",          limit: 2048
    t.string   "message",            limit: 16384
    t.string   "stacktrace",         limit: 2048
    t.string   "import_set_name",    limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "date_received"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
    t.string   "subject"
    t.boolean  "review_required"
    t.text     "body_original"
    t.datetime "date_sent"
    t.integer  "reviewer_id"
    t.string   "language"
    t.boolean  "rescinded",                default: false, null: false
    t.string   "action_taken"
    t.string   "type"
    t.integer  "original_notice_id"
    t.boolean  "spam",                     default: false
    t.boolean  "hidden",                   default: false
    t.string   "request_type"
    t.integer  "submission_id"
    t.string   "mark_registration_number"
    t.boolean  "published",                default: true,  null: false
    t.integer  "url_count"
    t.boolean  "webform",                  default: false
    t.text     "notes"
    t.integer  "counternotice_for_id"
    t.integer  "counternotice_for_sid"
  end

  add_index "notices", ["original_notice_id"], name: "index_notices_on_original_notice_id", using: :btree
  add_index "notices", ["reviewer_id"], name: "index_notices_on_reviewer_id", using: :btree
  add_index "notices", ["submission_id"], name: "index_notices_on_submission_id", using: :btree
  add_index "notices", ["type"], name: "index_notices_on_type", using: :btree

  create_table "notices_relevant_questions", force: :cascade do |t|
    t.integer "notice_id"
    t.integer "relevant_question_id"
  end

  add_index "notices_relevant_questions", ["notice_id"], name: "index_notices_relevant_questions_on_notice_id", using: :btree
  add_index "notices_relevant_questions", ["relevant_question_id"], name: "index_notices_relevant_questions_on_relevant_question_id", using: :btree

  create_table "notices_works", id: false, force: :cascade do |t|
    t.integer "notice_id"
    t.integer "work_id"
  end

  add_index "notices_works", ["notice_id"], name: "index_notices_works_on_notice_id", using: :btree
  add_index "notices_works", ["work_id"], name: "index_notices_works_on_work_id", using: :btree

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item"], name: "index_rails_admin_histories_on_item", using: :btree
  add_index "rails_admin_histories", ["month"], name: "index_rails_admin_histories_on_month", using: :btree
  add_index "rails_admin_histories", ["table"], name: "index_rails_admin_histories_on_table", using: :btree
  add_index "rails_admin_histories", ["year"], name: "index_rails_admin_histories_on_year", using: :btree

  create_table "reindex_runs", force: :cascade do |t|
    t.integer  "entity_count", default: 0
    t.integer  "notice_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reindex_runs", ["created_at"], name: "index_reindex_runs_on_created_at", using: :btree

  create_table "relevant_questions", force: :cascade do |t|
    t.text "question", null: false
    t.text "answer",   null: false
  end

  create_table "relevant_questions_topics", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "relevant_question_id"
  end

  add_index "relevant_questions_topics", ["relevant_question_id"], name: "index_relevant_questions_topics_on_relevant_question_id", using: :btree
  add_index "relevant_questions_topics", ["topic_id"], name: "index_relevant_questions_topics_on_topic_id", using: :btree

  create_table "risk_triggers", force: :cascade do |t|
    t.string  "field"
    t.string  "condition_field"
    t.string  "condition_value"
    t.boolean "negated"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "topic_assignments", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "notice_id"
  end

  add_index "topic_assignments", ["notice_id"], name: "index_topics_notices_on_notice_id", using: :btree
  add_index "topic_assignments", ["topic_id"], name: "index_topics_notices_on_topic_id", using: :btree

  create_table "topic_managers", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "topic_managers_topics", force: :cascade do |t|
    t.integer "topic_id"
    t.integer "topic_manager_id"
  end

  add_index "topic_managers_topics", ["topic_id"], name: "index_topic_managers_topics_on_topic_id", using: :btree
  add_index "topic_managers_topics", ["topic_manager_id"], name: "index_topic_managers_topics_on_topic_manager_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string  "name",                              null: false
    t.text    "description",          default: ""
    t.string  "ancestry"
    t.integer "original_category_id"
  end

  add_index "topics", ["ancestry"], name: "index_topics_on_ancestry", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "publication_delay",      default: 0,  null: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "works", force: :cascade do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
    t.text     "description_original"
  end

end
