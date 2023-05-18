RSpec.configure do |config|
  tables_to_skip_clean = %w[lumen_settings translations]

  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion, except: tables_to_skip_clean)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :search => true) do
    DatabaseCleaner.strategy = :deletion, { except: tables_to_skip_clean }
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :deletion, { except: tables_to_skip_clean }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
