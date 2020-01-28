class RemoveBlogEntryTopicAssignments < ActiveRecord::Migration[5.2]
  def change
    drop_table :blog_entry_topic_assignments, :force => true do |t|
      t.integer :blog_entry_id
      t.integer :topic_id
    end
  end
end
