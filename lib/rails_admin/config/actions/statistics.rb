require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

StatisticsProc = Proc.new do
  from = (Date.today - 1.month).beginning_of_day
  to = Date.today.end_of_day
  @token_urls_per_day = TokenUrl.where(created_at: from..to)
                                .group('date(created_at)')
                                .count
                                .to_json

  @notices_count = ActiveRecord::Base.connection.execute("select reltuples from pg_class where relname = 'notices';").getvalue(0, 0).to_i
  @copyrighted_urls_count = ActiveRecord::Base.connection.execute("select reltuples from pg_class where relname = 'copyrighted_urls';").getvalue(0, 0).to_i
  @infringing_urls_count = ActiveRecord::Base.connection.execute("select reltuples from pg_class where relname = 'infringing_urls';").getvalue(0, 0).to_i

  render @action.template_name
end

module RailsAdmin
  module Config
    module Actions
      class Statistics < Base
        register_instance_option(:http_methods) { %i( get ) }
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
