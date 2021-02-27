class AddCounternoticeForSidToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :counternotice_for_sid, :integer
  end
end
