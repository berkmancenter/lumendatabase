# See https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
RSpec.configure do |config|
  include Warden::Test::Helpers

  def sign_in(user)
    login_as(user, scope: :user)
  end

  def sign_out
    logout
  end

  config.after :each do
    Warden.test_reset!
  end
end
