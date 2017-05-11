RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:search]
      FakeWeb.clean_registry

      Notice.index.delete
      Notice.create_elasticsearch_index

      Entity.index.delete
      Entity.create_elasticsearch_index
    else
      FakeWeb.register_uri(:any, %r|\Ahttp://localhost:9200|, :body => "{}")
    end
  end
end