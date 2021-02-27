class CreateRelevantQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table(:relevant_questions) do |t|
      t.text :question
      t.text :answer
    end
  end
end
