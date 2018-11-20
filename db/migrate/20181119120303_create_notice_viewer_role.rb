class CreateNoticeViewerRole < ActiveRecord::Migration
  def change
    Role.create(name: 'notice_viewer')
  end
end
