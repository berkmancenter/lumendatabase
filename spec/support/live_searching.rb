RSpec.configure do |config|
  config.before(:suite) do
    Notice.__elasticsearch__.client.transport.reload_connections!
    Entity.__elasticsearch__.client.transport.reload_connections!
  end

  config.before(:each) do |example|
    begin
      Notice.__elasticsearch__.delete_index!
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e; end
    Notice.__elasticsearch__.create_index!

    begin
      Entity.__elasticsearch__.delete_index!
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e; end
    Entity.__elasticsearch__.create_index!
  end
end
