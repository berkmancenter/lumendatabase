Devise.setup do |config|

	require 'devise/orm/active_record'

	config.secret_key = '5717cc26815444da3e5b8b95154b7472e087f9acf62e15cbfa8cfd85d0409852bd04acf2e7cf6cb1793942219a301c5e4fc53b6b13f206ebe009227cd979c998'
	
  config.mailer_sender = "admin@chillingeffects.org"

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 10

  config.password_length = 8..128

  config.email_regexp = /\A[^@]+@[^@]+\z/

  config.reset_password_within = 6.hours
end
