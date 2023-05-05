Rails.application.config.to_prepare do
  # Preload all the exisiting translations
  Translation.load_all if ActiveRecord::Base.database_exists? && ActiveRecord::Base.connection.table_exists?('translations')
end
