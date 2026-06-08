# Form object for a public Lumen Enterprise sign-up. It validates the submitted
# data and creates the EnterpriseAccount in pre_registration status - no user and
# no payment yet. An admin later accepts or rejects the registration; the user is
# created on accept (see EnterpriseAccount#approve_registration!). On success it
# notifies the admins (with a link to review) and acknowledges the applicant.
class EnterpriseRegistration
  include ActiveModel::Model

  ATTRIBUTES = %i[
    email
    company_name
    company_contact_information
    representative_contact_information
    interested_domains
  ].freeze

  attr_accessor(*ATTRIBUTES)
  attr_reader :enterprise_account

  validates :email, presence: true
  validates :company_name, presence: true

  def save
    return false unless valid?

    @enterprise_account = build_enterprise_account
    @enterprise_account.save!

    send_notifications

    true
  rescue ActiveRecord::RecordInvalid
    import_record_errors
    false
  end

  private

  def build_enterprise_account
    EnterpriseAccount.new(
      name: company_name,
      applicant_email: email,
      company_contact_information: company_contact_information,
      representative_contact_information: representative_contact_information,
      interested_domains: interested_domains,
      status: 'pre_registration'
    )
  end

  def send_notifications
    Enterprise::RegistrationMailer
      .admin_review_request(enterprise_account)
      .deliver_later

    Enterprise::RegistrationMailer
      .client_registration_received(enterprise_account)
      .deliver_later
  end

  def import_record_errors
    copy_errors(enterprise_account, name: :company_name, applicant_email: :email)
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
