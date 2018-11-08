require 'validates_automatically'

class TokenUrl < ActiveRecord::Base
  include ValidatesAutomatically

  before_create :generate_token

  belongs_to :user
  belongs_to :notice

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless TokenUrl.exists?(token: random_token)
    end
  end
end
