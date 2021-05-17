require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
require 'action_view'

class StatisticsProcHelper
  include ActionView::Helpers::NumberHelper

  def fetch_formatted_count(table_name)
    number_with_delimiter(
      ActiveRecord::Base.connection.execute(
        "select reltuples from pg_class where relname = '#{table_name}';"
      )
        .getvalue(0, 0)
        .to_i
    )
  end

  def fetch_token_urls_per_day(params)
    from = params[:token_urls_per_day_from] || (Date.today - 1.month).beginning_of_day
    to = params[:token_urls_per_day_to] || Date.today.end_of_day

    ArchivedTokenUrl.where(created_at: from..to)
                    .group('date(created_at)')
                    .order('date(created_at)')
                    .count
                    .to_json
  end
end

StatisticsProc = Proc.new do
  helper = StatisticsProcHelper.new

  @token_urls_per_day = helper.fetch_token_urls_per_day(params)
  @token_urls_per_day_from = params[:token_urls_per_day_from] || (Date.today - 1.month)
  @token_urls_per_day_to = params[:token_urls_per_day_to] || Date.today
  @notices_count = helper.fetch_formatted_count('notices')
  @copyrighted_urls_count = helper.fetch_formatted_count('copyrighted_urls')
  @infringing_urls_count = helper.fetch_formatted_count('infringing_urls')

  render @action.template_name
end

module RailsAdmin
  module Config
    module Actions
      class Statistics < Base
        register_instance_option(:http_methods) { %i[get] }
        register_instance_option(:action_name) { :statistics }
        register_instance_option(:controller) { StatisticsProc }
        register_instance_option(:root?) { true }
        register_instance_option(:show_in_navigation) { false }
        register_instance_option(:show_in_sidebar) { true }
        register_instance_option(:link_icon) { false }
      end

      register Statistics
    end
  end
end
