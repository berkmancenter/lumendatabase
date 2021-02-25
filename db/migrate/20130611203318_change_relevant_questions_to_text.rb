class ChangeRelevantQuestionsToText < ActiveRecord::Migration[4.2]
  def change
    change_column :relevant_questions, :question, :text, null: false
    change_column :relevant_questions, :answer, :text, null: false
  end
end
