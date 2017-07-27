require 'rails_helper'

describe 'shared/_footer.html.erb' do
  include Devise::TestHelpers

  context 'signed in' do
    it 'gives a link to the admin' do
      allow(controller).to receive_messages(user_signed_in?: true)

      render

      expect(rendered).to have_css('a', text: 'Admin')
    end

  end

  context 'signed out' do
    it 'gives a link to sign in' do
      render

      expect(rendered).to have_css('a', text: 'Sign In')
    end

  end
end
