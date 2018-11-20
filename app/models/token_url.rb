require 'validates_automatically'

class TokenUrl < ActiveRecord::Base
  include ValidatesAutomatically

  before_create :generate_token

  belongs_to :user
  belongs_to :notice

  validates :email,
            allow_blank: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.validate_token(token, notice)
    return false if token.nil?
    return false unless (token_url = TokenUrl.find_by(token: token))
    return false if !token_url[:valid_forever] &&
                    (!token_url[:expiration_date].nil? &&
                     token_url[:expiration_date] < Time.now
                    )
    return false if token_url.notice != notice

    true
  end

  private

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless TokenUrl.exists?(token: random_token)
    end
  end
end
