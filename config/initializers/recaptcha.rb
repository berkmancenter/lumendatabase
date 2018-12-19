Recaptcha.configure do |config|
  # The keys here are just development keys provided by Google, publicly
  # available and will generate the test reCAPTCHA interface that shouldn't
  # be used in production
  config.site_key = ENV['RECAPTCHA_SITE_KEY'] || '6Lc6BAAAAAAAAChqRbQZcn_yyyyyyyyyyyyyyyyy'
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY'] || '6Lc6BAAAAAAAAKN3DRm6VA_xxxxxxxxxxxxxxxxx'
end
