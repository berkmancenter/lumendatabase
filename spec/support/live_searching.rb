RSpec.configure do |config|
  config.before(:each) do |example|
    Notice.__elasticsearch__.create_index!
    Notice.__elasticsearch__.delete_index!
    Notice.__elasticsearch__.create_index!

    Entity.__elasticsearch__.create_index!
    Entity.__elasticsearch__.delete_index!
    Entity.__elasticsearch__.create_index!
  end
end
