class CreateRelevantQuestions < ActiveRecord::Migration
  def change
    create_table(:relevant_questions) do |t|
      t.text :question
      t.text :answer
    end
  end
end
