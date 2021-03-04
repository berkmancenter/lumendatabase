class User < ApplicationRecord
  # == Relationships ========================================================
  has_one :entity
  has_and_belongs_to_many :roles
  has_many :token_urls
  has_and_belongs_to_many :full_notice_only_researchers_entities,
                          join_table: :entities_full_notice_only_researchers_users,
                          class_name: 'Entity'

  # == Extensions ===========================================================
  devise :database_authenticatable,
         :recoverable,           # New users are given a temp password to reset
         :validatable            # Ensures confirmation of Password on reset
  accepts_nested_attributes_for :entity

  # == Callbacks ============================================================
  before_save :ensure_authentication_token
  after_destroy do
    token_urls.where(valid_forever: false).destroy_all
  end

  # == Instance Methods =====================================================
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
