Devise.setup do |config|
  config.mailer_sender = "admin@chillingeffects.org"

  require 'devise/orm/active_record'

  # By default Devise will store the user in session. You can skip
  # storage for :http_auth and :token_auth by adding those symbols to
  # the array below.  Notice that if you are skipping storage for all
  # authentication paths, you may want to disable generating routes to
  # Devise's sessions controller by passing :skip => :sessions to
  # `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # For bcrypt, this is the cost for hashing the password and defaults
  # to 10. If using other encryptors, it sets how many times you want
  # the password re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the
  # performance of your test suite dramatically. However, it is STRONGLY
  # RECOMMENDED to not use a value less than 10 in other environments.
  config.stretches = Rails.env.test? ? 1 : 10

  # Range for password length. Default is 8..128.
  config.password_length = 8..128

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly to
  # give user feedback and not to assert the e-mail validity.
  config.email_regexp = /\A[^@]+@[^@]+\z/

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours
end
