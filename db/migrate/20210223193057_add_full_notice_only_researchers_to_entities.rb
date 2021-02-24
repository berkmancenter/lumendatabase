class AddFullNoticeOnlyResearchersToEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :entities_full_notice_only_researchers_users do |t|
      t.references :entity, index: true
      t.references :user, index: false
    end

    add_column :entities, :full_notice_only_researchers, :boolean
  end
end
