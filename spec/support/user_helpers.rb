module UserHelpers
  def login
    user = create(:user)
    visit '/users/sign_out' # clear old session
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'
    visit '/'
  end

  def logout
    visit '/users/sign_out' # clear old session
    visit '/'
  end
end
