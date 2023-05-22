# See https://medium.com/@rowanoulton/testing-elasticsearch-in-rails-22a3296d989 .
#require 'elasticsearch/extensions/test/cluster'

RSpec.configure do |config|
  searchable_models = [Notice, Entity]

  # Reload connections periodically to avoid test failures due to exhausting
  # the connection pool. (This may be a multithreading issue, with Capybara
  # and webrick running in different threads; in theory the connection pool
  # handling should be threadsafe but in practice maybe it isn't.)
  config.before :all, type: :integration do
    searchable_models.each do |model|
      begin
        model.__elasticsearch__.client.transport.reload_connections!
      rescue Elasticsearch::Transport::Transport::Errors::NotFound; end
    end
  end

  # Wipe Elasticsearch clean between tests.
  # First: delete content and indexes for indexed models. Then: recreate the
  # index.
  # Deleting the index alone doesn't suffice; you'll be left with content from
  # prior tests, which will be reindexed when you refresh the index.
  # The rescue blocks suppress noisy but irrelevant error messages.
  %i[feature controller view integration request].each do |type|
    config.before :each, type: type do
      searchable_models.each do |model|
        begin
          model.__elasticsearch__.create_index!
        rescue Elasticsearch::Transport::Transport::Errors::BadRequest; # This can happen when the index is created too fast I think?
        rescue Elasticsearch::Transport::Transport::Errors::NotFound; end
      end
    end

    config.after :each, type: type do
      searchable_models.each do |model|
        begin
          if model.__elasticsearch__.index_exists? index: model.__elasticsearch__.index_name
            model.__elasticsearch__.client.delete_by_query(
              index: model.index_name,
              q: '*'.freeze,
              body: {},
              refresh: true,
              conflicts: 'proceed'
            )
            model.__elasticsearch__.delete_index!
          end
        rescue Elasticsearch::Transport::Transport::Errors::NotFound; end
      end
    end
  end

end

# Must be 127.0.0.1 to let VCR match recorded urls, elasticsearch-ruby has an
# issue with reloading connections and even if we set it to localhost here on
# reconnection it will use 127.0.0.1 instead, that's why we need to use
# 127.0.0.1, at least for now, unless they fix the issue
#
# config = {
#   host: "http://127.0.0.1:#{9250 + ENV['TEST_ENV_NUMBER'].to_i}",
#   request_timeout: 20
# }
# 
# if ENV['LOG_ELASTICSEARCH'] == 'true'
#   config[:log] = true
#   config[:trace] = true
# end
# 
# Elasticsearch::Model.client = Elasticsearch::Client.new config
