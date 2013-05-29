# Bare minimum for now. Create users via console or admin panel with a
# temporary password; have them reset it via the Forgot link. All users
# are assumed admins and can access all of /admin.
class User < ActiveRecord::Base

  devise :database_authenticatable,
    :token_authenticatable, # API authentication
    :recoverable,           # New users are given a temp password to reset
    :validatable            # Ensures confirmation of Password on reset

  before_save :ensure_authentication_token

end
