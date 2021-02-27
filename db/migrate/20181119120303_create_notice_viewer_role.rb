class CreateNoticeViewerRole < ActiveRecord::Migration[4.2]
  def change
    Role.create(name: 'notice_viewer')
  end
end
