require 'capybara/rspec'
require 'capybara-screenshot/rspec'

# https://docs.travis-ci.com/user/common-build-problems/#capybara-im-getting-errors-about-elements-not-being-found
Capybara.default_max_wait_time = 60

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
  --disable-dev-shm-usage
  --headless=new
  --ignore-certificate-errors
  --incognito
  --mute-audio
  --remote-debugging-port=9222
  --no-sandbox
)

chrome_options = Selenium::WebDriver::Chrome::Options.new
default_chrome_options.each { |o| chrome_options.add_argument(o) }
client = Selenium::WebDriver::Remote::Http::Default.new(open_timeout: nil, read_timeout: 120)

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    clear_local_storage: true,
    clear_session_storage: true,
    options: chrome_options,
    http_client: client
  )
end

Capybara.javascript_driver = :selenium
Capybara.server = :webrick

Capybara.configure do |config|
  config.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
end

# Chromedriver intermittently reports a detached DOM node as a generic
# UnknownError ("Node with given id does not belong to the document") instead of
# the StaleElementReferenceError that Capybara already retries (see
# Capybara::Selenium::Driver#invalid_element_errors). This shows up in js: true
# specs when a JS-driven re-render (e.g. changing the sort order) tears a node
# out of the document while Capybara is filtering it for visibility. Because the
# error class isn't in the retry list, it bubbles up as a hard, flaky failure.
# Treat that specific error as retryable so Capybara's auto-wait absorbs the race.
module RetryDetachedNodeErrors
  DETACHED_NODE_MESSAGE = 'does not belong to the document'

protected

  def catch_error?(error, errors = nil)
    return true if detached_node_error?(error)

    super
  end

  def detached_node_error?(error)
    error.is_a?(::Selenium::WebDriver::Error::WebDriverError) &&
      error.message.to_s.include?(DETACHED_NODE_MESSAGE)
  end
end

Capybara::Node::Base.prepend(RetryDetachedNodeErrors)
