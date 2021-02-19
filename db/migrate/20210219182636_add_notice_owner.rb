class AddNoticeOwner < ActiveRecord::Migration[5.2]
  def change
    add_reference :notices, :user, index: true
  end
end
