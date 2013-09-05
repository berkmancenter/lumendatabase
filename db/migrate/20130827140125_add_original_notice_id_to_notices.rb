class AddOriginalNoticeIdToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :original_notice_id, :integer)
  end
end
