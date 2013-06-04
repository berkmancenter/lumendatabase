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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130604155451) do

  create_table "categories", :force => true do |t|
    t.string "name",        :null => false
    t.text   "description"
    t.string "ancestry"
    t.index ["ancestry"], :name => "index_categories_on_ancestry", :order => {"ancestry" => :asc}
  end

  create_table "categories_category_managers", :force => true do |t|
    t.integer "category_id"
    t.integer "category_manager_id"
    t.index ["category_id"], :name => "index_categories_category_managers_on_category_id", :order => {"category_id" => :asc}
    t.index ["category_manager_id"], :name => "index_categories_category_managers_on_category_manager_id", :order => {"category_manager_id" => :asc}
  end

  create_table "categories_notices", :force => true do |t|
    t.integer "category_id"
    t.integer "notice_id"
    t.index ["category_id"], :name => "index_categories_notices_on_category_id", :order => {"category_id" => :asc}
    t.index ["notice_id"], :name => "index_categories_notices_on_notice_id", :order => {"notice_id" => :asc}
  end

  create_table "categories_relevant_questions", :force => true do |t|
    t.integer "category_id"
    t.integer "relevant_question_id"
    t.index ["category_id"], :name => "index_categories_relevant_questions_on_category_id", :order => {"category_id" => :asc}
    t.index ["relevant_question_id"], :name => "index_categories_relevant_questions_on_relevant_question_id", :order => {"relevant_question_id" => :asc}
  end

  create_table "category_managers", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.index ["priority", "run_at"], :name => "delayed_jobs_priority", :order => {"priority" => :asc, "run_at" => :asc}
  end

  create_table "entities", :force => true do |t|
    t.string "name",                                     :null => false
    t.string "kind",           :default => "individual", :null => false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "state"
    t.string "country_code"
    t.string "phone"
    t.string "email"
    t.string "url"
    t.string "ancestry"
    t.string "city"
    t.string "zip"
    t.index ["ancestry"], :name => "index_entities_on_ancestry", :order => {"ancestry" => :asc}
  end

  create_table "entity_notice_roles", :force => true do |t|
    t.integer  "entity_id",  :null => false
    t.integer  "notice_id",  :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.index ["entity_id"], :name => "index_entity_notice_roles_on_entity_id", :order => {"entity_id" => :asc}
    t.index ["notice_id"], :name => "index_entity_notice_roles_on_notice_id", :order => {"notice_id" => :asc}
  end

  create_table "file_uploads", :force => true do |t|
    t.integer  "notice_id"
    t.string   "kind"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.index ["notice_id"], :name => "index_file_uploads_on_notice_id", :order => {"notice_id" => :asc}
  end

  create_table "infringing_urls", :force => true do |t|
    t.string   "url",        :limit => 1024, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "infringing_urls_works", :id => false, :force => true do |t|
    t.integer "infringing_url_id", :null => false
    t.integer "work_id",           :null => false
    t.index ["infringing_url_id"], :name => "index_infringing_urls_works_on_infringing_url_id", :order => {"infringing_url_id" => :asc}
    t.index ["work_id"], :name => "index_infringing_urls_works_on_work_id", :order => {"work_id" => :asc}
  end

  create_table "notices", :force => true do |t|
    t.string   "title",         :null => false
    t.text     "body"
    t.datetime "date_received"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "source"
    t.string   "subject"
  end

  create_table "notices_relevant_questions", :force => true do |t|
    t.integer "notice_id"
    t.integer "relevant_question_id"
    t.index ["notice_id"], :name => "index_notices_relevant_questions_on_notice_id", :order => {"notice_id" => :asc}
    t.index ["relevant_question_id"], :name => "index_notices_relevant_questions_on_relevant_question_id", :order => {"relevant_question_id" => :asc}
  end

  create_table "notices_works", :id => false, :force => true do |t|
    t.integer "notice_id"
    t.integer "work_id"
    t.index ["notice_id"], :name => "index_notices_works_on_notice_id", :order => {"notice_id" => :asc}
    t.index ["work_id"], :name => "index_notices_works_on_work_id", :order => {"work_id" => :asc}
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.index ["item"], :name => "index_rails_admin_histories_on_item", :order => {"item" => :asc}
    t.index ["month"], :name => "index_rails_admin_histories_on_month", :order => {"month" => :asc}
    t.index ["table"], :name => "index_rails_admin_histories_on_table", :order => {"table" => :asc}
    t.index ["year"], :name => "index_rails_admin_histories_on_year", :order => {"year" => :asc}
  end

  create_table "relevant_questions", :force => true do |t|
    t.string "question", :null => false
    t.string "answer",   :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
    t.index ["tag_id"], :name => "index_taggings_on_tag_id", :order => {"tag_id" => :asc}
    t.index ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context", :order => {"taggable_id" => :asc, "taggable_type" => :asc, "context" => :asc}
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.index ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true, :order => {"authentication_token" => :asc}
    t.index ["email"], :name => "index_users_on_email", :unique => true, :order => {"email" => :asc}
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true, :order => {"reset_password_token" => :asc}
  end

  create_table "works", :force => true do |t|
    t.string   "url",         :limit => 1024, :null => false
    t.text     "description"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "kind"
  end

end
