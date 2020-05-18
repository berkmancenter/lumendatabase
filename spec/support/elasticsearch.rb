# See https://medium.com/@rowanoulton/testing-elasticsearch-in-rails-22a3296d989 .
require 'elasticsearch/extensions/test/cluster'

RSpec.configure do |config|
  # The ENV['TEST_ENV_NUMBER'] things are needed to ensure test isolation
  # when parallelizing.
  es_port = 9250 + ENV['TEST_ENV_NUMBER'].to_i
  es_options = {
    network_host: 'localhost',
    port: es_port,
    number_of_nodes: 1,
    timeout: 120,
    cluster_name: "cluster#{ENV['TEST_ENV_NUMBER']}",
    path_data: "/tmp/elasticsearch_test#{ENV['TEST_ENV_NUMBER']}"
  }
  if ENV['TEST_CLUSTER_COMMAND'].present?
    es_options[:command] = ENV['TEST_CLUSTER_COMMAND']
  end

  searchable_models = [Notice, Entity]

  # Start an in-memory Elasticsearch cluster for integration tests. Runs on
  # port 9250 so as not to interfere with development/production clusters.
  # This may throw a warning that the cluster is already running, but you can
  # ignore that.
  # There are enough tests that require Elasticsearch that it's a pain to
  # restrict this to integration tests. However, if you're running a model test
  # or something else you know doesn't require ES, you can use ENV to test
  # without Elasticsearch, since it's faster.
  config.before :suite do
    next if ENV['TEST_WITH_ELASTICSEARCH'].to_s == "0"
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
  %i[feature controller view integration request].each do |type|
    config.before :each, type: type do
      searchable_models.each do |model|
        begin
          if model.__elasticsearch__.index_exists? index: model.__elasticsearch__.index_name
            model.__elasticsearch__.client.delete_by_query(
              index: model.__elasticsearch__.index_name, q: '.'.freeze
            )
            model.__elasticsearch__.delete_index!
          end
        rescue Elasticsearch::Transport::Transport::Errors::NotFound; end

        begin
          model.__elasticsearch__.create_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound; end
      end
    end
  end

  # Stop elasticsearch cluster after test run
  config.after :suite do
    if Elasticsearch::Extensions::Test::Cluster.running?(on: es_port)
      Elasticsearch::Extensions::Test::Cluster.stop(**es_options)
    end
  end
end

# Must be 127.0.0.1 to let VCR match recorded urls, elasticsearch-ruby has an
# issue with reloading connections and even if we set it to localhost here on
# reconnection it will use 127.0.0.1 instead, that's why we need to use
# 127.0.0.1, at least for now, unless they fix the issue
config = {
  host: "http://127.0.0.1:#{9250 + ENV['TEST_ENV_NUMBER'].to_i}",
  request_timeout: 20
}

if ENV['LOG_ELASTICSEARCH'] == 'true'
  config[:log] = true
  config[:trace] = true
end

Elasticsearch::Model.client = Elasticsearch::Client.new config
