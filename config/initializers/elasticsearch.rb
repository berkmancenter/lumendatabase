config = {
  host: 'http://localhost:9200',
  request_timeout: 20
}

if File.exist?('config/elasticsearch.yml')
  config.merge!(YAML.load_file('config/elasticsearch.yml')[Rails.env]
    .symbolize_keys)
end

config[:host] = ENV['ELASTICSEARCH_URL'] || config[:host]

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
