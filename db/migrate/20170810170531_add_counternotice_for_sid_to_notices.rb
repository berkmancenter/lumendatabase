class AddCounternoticeForSidToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :counternotice_for_sid, :integer
  end
end
