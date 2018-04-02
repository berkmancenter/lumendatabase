class AddCounternoticeForIdToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :counternotice_for_id, :integer
  end
end
