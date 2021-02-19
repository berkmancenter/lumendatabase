class AddOriginalNoticeIdToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :original_notice_id, :integer)
  end
end
