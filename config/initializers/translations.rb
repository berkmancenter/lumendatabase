Rails.application.config.to_prepare do
  begin
    # Preload all the exisiting translations
    Translation.load_all if ActiveRecord::Base.database_exists? && ActiveRecord::Base.connection.table_exists?('translations')
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad
    # Allow to start the application without a database, when running "rails db:create"
    nil
  end
end
