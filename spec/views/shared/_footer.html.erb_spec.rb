require 'rails_helper'

describe 'shared/_footer.html.erb' do
  include Devise::TestHelpers

  context 'signed in' do
    it 'gives a link to the admin for admin users' do
      allow(controller).to receive_messages(user_signed_in?: true)
      allow(controller.current_user).to receive(:has_role?)
        .with(Role.admin)
        .and_return(true)

      render

      expect(rendered).to have_css('a', text: 'Admin')
    end

    it 'does not give a link to the admin for non-admin users' do
      allow(controller).to receive_messages(user_signed_in?: true)
      allow(controller.current_user).to receive(:has_role?)
        .with(Role.admin)
        .and_return(false)

      render

      expect(rendered).not_to have_css('a', text: 'Admin')
    end

    it 'gives a link to sign out' do
      allow(controller).to receive_messages(user_signed_in?: true)

      # It doesn't matter what we return here, but we do need to define the
      # behavior or the spec will fail when the template tries to call
      # current_user.has_role?
      allow(controller.current_user).to receive(:has_role?)
        .with(Role.admin)
        .and_return(false)

      render

      expect(rendered).to have_css('a', text: 'Sign Out')

      # Make sure admins see the link also.
      allow(controller.current_user).to receive(:has_role?)
        .with(Role.admin)
        .and_return(true)

      render

      expect(rendered).to have_css('a', text: 'Sign Out')
    end
  end

  context 'signed out' do
    it 'gives a link to sign in' do
      render

      expect(rendered).to have_css('a', text: 'Sign In')
    end
  end
end
