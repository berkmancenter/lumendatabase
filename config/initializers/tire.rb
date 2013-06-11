Tire.configure do
  url ENV["ELASTICSEARCH_URL"] || "http://localhost:9200"
end
