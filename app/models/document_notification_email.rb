class DocumentNotificationEmail < ApplicationRecord
  before_validation :generate_token

  belongs_to :notice

  validates :notice, presence: true
  validates :email_address, presence: true
  validates :token, presence: true

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(nil, false) if self.token.nil?
  end
end
