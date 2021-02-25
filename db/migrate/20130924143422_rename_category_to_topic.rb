class RenameCategoryToTopic < ActiveRecord::Migration[4.2]
  def change
    create_table "blog_entry_topic_assignments", :force => true do |t|
      t.integer "blog_entry_id"
      t.integer "topic_id"
    end

    add_index "blog_entry_topic_assignments", ["blog_entry_id"], :name => "index_blog_entry_topic_assignments_on_blog_entry_id"
    add_index "blog_entry_topic_assignments", ["topic_id"], :name => "index_blog_entry_topic_assignments_on_topic_id"

    create_table "topics", :force => true do |t|
      t.string  "name",                 :null => false
      t.text    "description"
      t.string  "ancestry"
      t.integer "original_category_id"
    end

    add_index "topics", ["ancestry"], :name => "index_topics_on_ancestry"

    create_table "topic_managers_topics", :force => true do |t|
      t.integer "topic_id"
      t.integer "topic_manager_id"
    end

    add_index "topic_managers_topics", ["topic_id"], :name => "index_topic_managers_topics_on_topic_id"
    add_index "topic_managers_topics", ["topic_manager_id"], :name => "index_topic_managers_topics_on_topic_manager_id"

    create_table "relevant_questions_topics", :force => true do |t|
      t.integer "topic_id"
      t.integer "relevant_question_id"
    end

    add_index "relevant_questions_topics", ["topic_id"], :name => "index_relevant_questions_topics_on_topic_id"
    add_index "relevant_questions_topics", ["relevant_question_id"], :name => "index_relevant_questions_topics_on_relevant_question_id"

    create_table "topic_assignments", :force => true do |t|
      t.integer "topic_id"
      t.integer "notice_id"
    end

    add_index "topic_assignments", ["topic_id"], :name => "index_topics_notices_on_topic_id"
    add_index "topic_assignments", ["notice_id"], :name => "index_topics_notices_on_notice_id"

    create_table "topic_managers", :force => true do |t|
      t.string "name", :null => false
    end

    ['blog_entry_categorizations', 'categories', 
     'categories_category_managers', 'categories_relevant_questions',
     'categorizations', 'category_managers'].each do |table|
       drop_table table
    end
  end
end
