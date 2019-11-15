class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,           # New users are given a temp password to reset
         :validatable            # Ensures confirmation of Password on reset

  before_save :ensure_authentication_token

  has_one :entity
  has_and_belongs_to_many :roles
  has_many :token_urls, dependent: :destroy
  accepts_nested_attributes_for :entity

  def role?(role)
    roles.include?(role)
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
