Tire.configure do
  url ENV["ELASTICSEARCH_URL"] || "http://localhost:9200"
end

Tire::Model::Search.index_prefix  "#{Rails.env.to_s.downcase}_"
