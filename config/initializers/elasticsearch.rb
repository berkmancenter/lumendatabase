config = {
  host: 'http://localhost:9200',
  # This request timeout is ridiculously large, but searches with a very large
  # number of hits will fail without it (throwing a Faraday::TimeoutError
  # (Net::ReadTimeout)).
  request_timeout: 40
}

if File.exist?('config/elasticsearch.yml')
  config.merge!(YAML.load_file('config/elasticsearch.yml')[Rails.env]
    .symbolize_keys)
end

config[:host] = ENV['ELASTICSEARCH_URL'] || config[:host]

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
