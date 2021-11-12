require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
require 'action_view'

TopNoticesTokenUrlsProc = Proc.new do
  @model_config.list.exclude_fields(*Notice.column_names.map(&:to_sym), :time_to_publish, :entities, :topics, :works)
  @model_config.list.include_fields(:id, :title, :created_at, :token_urls_count)
  @objects = list_entries(@model_config, :index, :top_notices_token_urls).reorder('counted_archived_token_urls DESC')

  render 'index'
end

module RailsAdmin
  module Config
    module Actions
      class TopNoticesTokenUrls < Base
        register_instance_option(:collection) { true }
        register_instance_option(:controller) { TopNoticesTokenUrlsProc }
        register_instance_option(:link_icon) { 'icon-th-list' }
        register_instance_option(:only) { Notice }
      end

      register TopNoticesTokenUrls
    end
  end
end
