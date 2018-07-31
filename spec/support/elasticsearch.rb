# See https://medium.com/@rowanoulton/testing-elasticsearch-in-rails-22a3296d989 .
require 'elasticsearch/extensions/test/cluster'

RSpec.configure do |config|

  es_port = 9250 # should match the setting for elasticsearch.yml#test
  es_options = {
    network_host: 'localhost',
    port: es_port,
    number_of_nodes: 1,
    timeout: 120,
    command: ENV['TEST_CLUSTER_COMMAND']
  }
  # Start an in-memory Elasticsearch cluster for integration tests. Runs on
  # port 9250 so as not to interfere with development/production clusters.
  config.before :all, type: :request do
    Elasticsearch::Extensions::Test::Cluster.start(**es_options) unless Elasticsearch::Extensions::Test::Cluster.running?(on: es_port)

    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        model.__elasticsearch__.client.transport.reload_connections!
      end
    end
  end

  # Stop elasticsearch cluster after test run
  config.after :suite do
    Elasticsearch::Extensions::Test::Cluster.stop(**es_options) if Elasticsearch::Extensions::Test::Cluster.running?(on: es_port)
  end

# Create indexes for all elastic-searchable models
  config.before :each, search: true do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.create_index!
          # Refresh is a blocking method. This is great because it obviates
          # the need for, and is more reliable than, sleep calls.
          model.__elasticsearch__.refresh_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound;
          # This kills "Index does not exist" errors being written to console
          # by this: https://github.com/elastic/elasticsearch-rails/blob/738c63efacc167b6e8faae3b01a1a0135cfc8bbb/elasticsearch-model/lib/elasticsearch/model/indexing.rb#L268
        end
      end
    end
  end

  # Delete indexes for all elastic searchable models to ensure clean state between tests
  config.after :each, search: true do
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__)
        begin
          model.__elasticsearch__.delete_index!
        rescue Elasticsearch::Transport::Transport::Errors::NotFound;
        end
      end
    end
  end
end
