class CreateNoticesRelevantQuestions < ActiveRecord::Migration
  def change
    create_table(:notices_relevant_questions) do |t|
      t.belongs_to :notice
      t.belongs_to :relevant_question
    end

    add_index(:notices_relevant_questions, :notice_id)
    add_index(:notices_relevant_questions, :relevant_question_id)
  end
end
