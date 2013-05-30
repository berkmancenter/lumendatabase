class CreateCategoriesRelevantQuestions < ActiveRecord::Migration
  def change
    create_table(:categories_relevant_questions) do |t|
      t.belongs_to :category
      t.belongs_to :relevant_question
    end

    add_index(:categories_relevant_questions, :category_id)
    add_index(:categories_relevant_questions, :relevant_question_id)
  end
end
