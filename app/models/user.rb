class User < ActiveRecord::Base

  devise :database_authenticatable,
    :recoverable,           # New users are given a temp password to reset
    :validatable            # Ensures confirmation of Password on reset

  has_one :entity
  has_and_belongs_to_many :roles
  accepts_nested_attributes_for :entity

  def has_role?(role)
    self.roles.include?(role)
  end
end
