require './lib/kaminari/active_record_relation_methods'

Chill::Application.config.tables_using_naive_counts =
  (ENV['TABLES_USING_NAIVE_COUNTS'] || 'infringing_urls').split(',')
