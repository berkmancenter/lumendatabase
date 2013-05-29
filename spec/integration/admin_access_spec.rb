require 'spec_helper'

feature "admin access" do
  scenario "a user must sign in to access admin" do
    user = create(:user)

    visit '/admin'

    expect(current_path).to eq '/users/sign_in'

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password

    click_on "Sign in"

    expect(current_path).to eq '/admin/'
  end
end
