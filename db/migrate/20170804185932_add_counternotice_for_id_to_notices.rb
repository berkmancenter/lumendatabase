class AddCounternoticeForIdToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :counternotice_for_id, :integer
  end
end
