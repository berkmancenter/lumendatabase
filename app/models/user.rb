class User < ApplicationRecord
  extend Devise::Models

  # == Relationships ========================================================
  belongs_to :entity, optional: true
  belongs_to :enterprise_account, optional: true
  has_and_belongs_to_many :roles
  has_many :token_urls
  has_many :requested_enterprise_reports,
           class_name: 'EnterpriseReport',
           foreign_key: :requested_by_id,
           dependent: :nullify
  has_many :enterprise_domains, through: :enterprise_account
  has_and_belongs_to_many :full_notice_only_researchers_entities,
                          join_table: :entities_full_notice_only_researchers_users,
                          class_name: 'Entity'
  has_one :api_submitter_request

  # == Extensions ===========================================================
  devise :database_authenticatable,
         :recoverable,           # New users are given a temp password to reset
         :validatable            # Ensures confirmation of Password on reset
  accepts_nested_attributes_for :entity

  # == Callbacks ============================================================
  before_save :ensure_authentication_token,
              :ensure_widget_public_key
  after_destroy do
    token_urls.where(valid_forever: false).destroy_all
  end

  # == Scopes ===============================================================
  Role::NAMES.each do |role|
    scope "#{role}s", -> { joins(:roles).where(roles: { name: role }) }
  end

  # == Instance Methods =====================================================
  def role?(role)
    role_name = role.respond_to?(:name) ? role.name : role.to_s

    role_names.include?(role_name)
  end

  def enterprise?
    role?(:enterprise)
  end

  def active_enterprise_account
    return unless enterprise? && enterprise_email_confirmed?

    enterprise_account if enterprise_account&.pro?
  end

  # True once the user has confirmed the email they registered with. Gates both
  # Pro access (above) and access to the settings/payment pages (below).
  def enterprise_email_confirmed?
    enterprise_email_confirmed_at.present?
  end

  # An approved enterprise user who has confirmed their email but may not have
  # paid yet. Lets them reach the settings page to choose a Pro plan.
  def confirmed_enterprise_user?
    enterprise? && enterprise_email_confirmed? && enterprise_account&.approved?
  end

  # Mark the registered email confirmed and burn the single-use token.
  def confirm_enterprise_email!
    update!(
      enterprise_email_confirmed_at: Time.current,
      enterprise_email_confirmation_token: nil
    )
  end

  # Assign a unique single-use confirmation token. Called explicitly when an
  # admin accepts a registration, never as a global callback, so non-enterprise
  # users never receive one.
  def assign_enterprise_email_confirmation_token
    self.enterprise_email_confirmation_token = generate_enterprise_email_confirmation_token
  end

  def enterprise_cache_key
    return 'no-enterprise' unless active_enterprise_account

    domains_updated_at = active_enterprise_account
                         .enterprise_domains
                         .maximum(:updated_at)
                         &.to_i

    [
      'enterprise',
      active_enterprise_account.cache_key_with_version,
      domains_updated_at
    ].join('-')
  end

  def ensure_authentication_token
    return unless authentication_token.blank?

    self.authentication_token = generate_authentication_token
  end

  def ensure_widget_public_key
    return unless widget_public_key.blank?

    self.widget_public_key = generate_widget_public_key
  end

  private

  def role_names
    @role_names ||= roles.map(&:name)
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def generate_widget_public_key
    loop do
      token = Devise.friendly_token
      break token unless User.where(widget_public_key: token).first
    end
  end

  def generate_enterprise_email_confirmation_token
    loop do
      token = SecureRandom.hex(16)
      break token unless User.exists?(enterprise_email_confirmation_token: token)
    end
  end
end
