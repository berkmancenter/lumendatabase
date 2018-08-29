# See https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
include Warden::Test::Helpers

RSpec.configure do |config|

  def sign_in(user)
    login_as(user, :scope => :user)
  end

  config.after :each do
    Warden.test_reset!
  end
end
