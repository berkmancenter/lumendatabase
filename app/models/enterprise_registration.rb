# Form object that orchestrates a public Lumen Enterprise sign-up: it validates
# the submitted data, then transactionally creates the EnterpriseAccount, the
# Devise user, assigns the enterprise role, applies the payment-method rules and
# sends the notification emails. Plan and paid_until are always derived here,
# never trusted from the browser.
class EnterpriseRegistration
  include ActiveModel::Model

  ATTRIBUTES = %i[
    email
    password
    password_confirmation
    company_name
    company_contact_information
    representative_contact_information
    payment_method
  ].freeze

  attr_accessor(*ATTRIBUTES)
  attr_reader :user, :enterprise_account

  validates :email, presence: true
  validates :password, presence: true
  validates :company_name, presence: true
  validates :payment_method,
            inclusion: {
              in: EnterpriseAccount::PAYMENT_METHODS,
              message: 'must be selected'
            }
  validate :passwords_match

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @enterprise_account = build_enterprise_account
      @enterprise_account.save!
      @user = build_user(@enterprise_account)
      @user.save!
    end

    send_notifications

    true
  rescue ActiveRecord::RecordInvalid
    import_record_errors
    false
  end

  def pro?
    enterprise_account&.pro?
  end

  private

  def build_enterprise_account
    account = EnterpriseAccount.new(
      name: company_name,
      company_contact_information: company_contact_information,
      representative_contact_information: representative_contact_information,
      payment_method: payment_method
    )

    apply_payment_method(account)

    account
  end

  # The plan and paid period are decided on the server based purely on the
  # chosen payment method, never on anything the form posts directly.
  def apply_payment_method(account)
    if payment_method == 'credit_card'
      account.extend_pro_access!
    else
      account.plan = 'inactive'
    end
  end

  def build_user(account)
    User.new(
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      enterprise_account: account,
      roles: [Role.enterprise]
    )
  end

  def send_notifications
    Enterprise::RegistrationMailer
      .admin_notification(enterprise_account, user)
      .deliver_later

    Enterprise::RegistrationMailer
      .client_confirmation(enterprise_account, user)
      .deliver_later
  end

  def passwords_match
    return if password.blank?
    return if password == password_confirmation

    errors.add(:password_confirmation, "doesn't match Password")
  end

  def import_record_errors
    copy_errors(user, email: :email,
                      password: :password,
                      password_confirmation: :password_confirmation)
    copy_errors(enterprise_account, name: :company_name)
  end

  def copy_errors(record, mapping)
    return if record.nil?

    record.errors.each do |error|
      target = mapping.fetch(error.attribute, :base)
      message = target == :base ? error.full_message : error.message

      next if errors.added?(target, message)

      errors.add(target, message)
    end
  end
end
