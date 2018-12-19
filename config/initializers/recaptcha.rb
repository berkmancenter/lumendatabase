Recaptcha.configure do |config|
  # The keys here are just development keys provided by Google, publicly
  # available and will generate the test reCAPTCHA interface that shouldn't
  # be used in production
  config.site_key = ENV['RECAPTCHA_SITE_KEY'] || '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY'] || '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe'
end
