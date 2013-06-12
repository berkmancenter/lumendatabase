class RenameCategoriesNoticesToCategorizations < ActiveRecord::Migration
  def change
    rename_table(:categories_notices, :categorizations)
  end
end
