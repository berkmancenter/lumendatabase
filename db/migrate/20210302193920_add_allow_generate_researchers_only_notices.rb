class AddAllowGenerateResearchersOnlyNotices < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :allow_generate_permanent_tokens_researchers_only_notices, :boolean
  end
end
