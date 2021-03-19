require 'validates_automatically'
require 'securerandom'

class ApiSubmitterRequest < ApplicationRecord
  include ValidatesAutomatically

  # == Relationships ========================================================
  belongs_to :user

  # == Validations ==========================================================
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # == Instance Methods =====================================================

  def approve_request
    new_entity = Entity.create!(
      name: self.entity_name,
      kind: self.entity_kind,
      address_line_1: self.entity_address_line_1,
      address_line_2: self.entity_address_line_2,
      state: self.entity_state,
      country_code: self.entity_country_code,
      phone: self.entity_phone,
      url: self.entity_url,
      email: self.entity_email,
      city: self.entity_city,
      zip: self.entity_zip
    )

    password = SecureRandom.hex
    new_user = User.create!(
      email: self.email,
      roles: [Role.submitter],
      password: password,
      entity: new_entity
    )

    self.user = new_user
    self.approved = true
    self.save!

    ApiSubmitterRequestsMailer.api_submitter_request_approved(new_user)
                              .deliver_later
  end

  def reject_request
    self.approved = false
    self.save!

    ApiSubmitterRequestsMailer.api_submitter_request_rejected(self)
                              .deliver_later
  end
end
