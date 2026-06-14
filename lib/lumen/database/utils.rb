module Lumen::Database::Utils
  def database_exists?
    begin
      connection
    rescue ActiveRecord::NoDatabaseError
      return false
    end
    true
  end
end
