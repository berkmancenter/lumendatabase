class User < ActiveRecord::Base

  devise :database_authenticatable,
    :token_authenticatable, # API authentication
    :recoverable,           # New users are given a temp password to reset
    :validatable            # Ensures confirmation of Password on reset

  has_and_belongs_to_many :roles

  before_save :ensure_authentication_token

  def has_role?(role)
    self.roles.include?(role)
  end
end
