# See https://medium.com/@rowanoulton/testing-elasticsearch-in-rails-22a3296d989 .
require 'elasticsearch/extensions/test/cluster'

RSpec.configure do |config|
  es_port = 9250
  es_options = {
    network_host: 'localhost',
    port: es_port,
    number_of_nodes: 1,
    timeout: 120
  }
  if ENV['TEST_CLUSTER_COMMAND'].present?
    es_options[:command] = ENV['TEST_CLUSTER_COMMAND']
  end

  searchable_models = [Notice, Entity]

  # Start an in-memory Elasticsearch cluster for integration tests. Runs on
  # port 9250 so as not to interfere with development/production clusters.
  # This may throw a warning that the cluster is already running, but you can
  # ignore that.
  config.before :suite do
    if Elasticsearch::Extensions::Test::Cluster.running?(on: es_port)
      Elasticsearch::Extensions::Test::Cluster.stop(**es_options)
    end
    Elasticsearch::Extensions::Test::Cluster.start(**es_options)
  end

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
  %i[feature controller view integration].each do |type|
    config.before :each, type: type do
      searchable_models.each do |model|
        begin
          model.__elasticsearch__.client.delete_by_query(
            index: model.__elasticsearch__.index_name
          )
          model.__elasticsearch__.delete_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound; end

        begin
          model.__elasticsearch__.create_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound; end
      end
    end
  end

  # Stop elasticsearch cluster after test run
  config.after :suite do
    Elasticsearch::Extensions::Test::Cluster.stop(**es_options)
  end
end

# Must be 127.0.0.1 to let VCR match recorded urls, elasticsearch-ruby has an
# issue with reloading connections and even if we set it to localhost here on
# reconnection it will use 127.0.0.1 instead, that's why we need to use
# 127.0.0.1, at least for now, unless they fix the issue
config = {
  host: 'http://127.0.0.1:9250',
  request_timeout: 20
}

if ENV['LOG_ELASTICSEARCH'] == 'true'
  config[:log] = true
  config[:trace] = true
end

Elasticsearch::Model.client = Elasticsearch::Client.new config
