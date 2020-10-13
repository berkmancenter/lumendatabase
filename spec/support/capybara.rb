require 'capybara/rspec'
require 'webdrivers/chromedriver'

# https://docs.travis-ci.com/user/common-build-problems/#capybara-im-getting-errors-about-elements-not-being-found
Capybara.default_max_wait_time = 15

# TROUBLESHOOTING: are your tests failing because of the wrong chromedriver
# version, even though you know you have the right version installed, and
# moreover webdrivers is automatically managing the upgrades?
# Before you go editing these options, check for running Chrome processes and
# kill them! Old running Chrome versions will disrupt Capybara's ability to find
# and launch the new version.
default_chrome_options = %w(
  --blink-settings=imagesEnabled=false
  --disable-extensions
  --disable-gpu
  --disable-infobars
  --disable-notifications
  --disable-password-generation
  --disable-password-manager-reauthentication
  --disable-popup-blocking
  --disable-save-password-bubble
  --headless
  --ignore-certificate-errors
  --incognito
  --mute-audio
  --remote-debugging-port=9222
)

chrome_options = Selenium::WebDriver::Chrome::Options.new
default_chrome_options.each { |o| chrome_options.add_argument(o) }
client = Selenium::WebDriver::Remote::Http::Default.new(open_timeout: nil, read_timeout: 120)

Capybara.register_driver :headless do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    clear_local_storage: true,
    clear_session_storage: true,
    options: chrome_options,
    http_client: client
  )
end

Capybara.javascript_driver = :headless
Capybara.server = :webrick

Capybara.configure do |config|
  config.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
end
