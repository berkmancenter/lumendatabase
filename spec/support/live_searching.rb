RSpec.configure do |config|
  config.before(:each, search: false) do
    # Mock Elasticsearch for non-search scenarios
    FakeWeb.register_uri(:any, %r|\Ahttp://localhost:9200|, :body => "{}")
  end

  config.before(:each, search: true) do
    Notice.index.delete
    Notice.create_elasticsearch_index

    Trademark.index.delete
    Trademark.create_elasticsearch_index

    Entity.index.delete
    Entity.create_elasticsearch_index
  end
end
