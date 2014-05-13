require './lib/kaminari/active_record_relation_methods'

# Prevents conflicts between Kaminari (used by rails_admin) and
# will_paginate.
Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end

Chill::Application.config.tables_using_naive_counts =
  (ENV['TABLES_USING_NAIVE_COUNTS'] || 'infringing_urls').split(',')
