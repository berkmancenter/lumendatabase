class UpdateUserLimitedViewSettings < ActiveRecord::Migration
  def change
    User.where(notice_viewer_viewed_notices: nil)
        .update_all(notice_viewer_viewed_notices: 0)

    change_column :users,
                  :notice_viewer_viewed_notices,
                  :integer,
                  default: 0,
                  null: false
    change_column :users,
                  :can_generate_permanent_notice_token_urls,
                  :boolean,
                  default: false,
                  null: false
    change_column :users,
                  :limit_notice_api_response,
                  :boolean,
                  default: false,
                  null: false
  end
end
