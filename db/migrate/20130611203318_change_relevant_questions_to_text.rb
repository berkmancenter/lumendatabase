class ChangeRelevantQuestionsToText < ActiveRecord::Migration
  def change
    change_column :relevant_questions, :question, :text, null: false
    change_column :relevant_questions, :answer, :text, null: false
  end
end
