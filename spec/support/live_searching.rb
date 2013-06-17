module LiveSearching
  def enable_live_searches
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true

    Notice.index.delete
    Notice.create_elasticsearch_index
  end
end

RSpec.configure do |config|
  config.include LiveSearching
end
