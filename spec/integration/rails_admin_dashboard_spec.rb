require 'rails_helper'

feature 'Rails admin dashboard' do
  before do
    AdminOnPage.new(create(:user, :redactor)).tap(&:sign_into_admin)
  end

  scenario 'It displays proper labels for Notice subclasses in the sidebar' do
    within('.sidebar-nav') do
      expect(page).to have_css('a', text: /^Notices$/, count: 1)

      Notice.type_models.each do |model|
        expect(page).to have_css("a:contains('#{model.label}')")
      end
    end
  end

  scenario 'it does not display the model counts' do
    within('#block-tables .content') do
      expect(page).to have_no_css('.bar')
      expect(page).to have_no_content('Notice')
      expect(page).to have_no_content('Infringing url')
    end
  end

  scenario 'it can delete notices' do
    notice = create(:dmca)
    orig_id = notice.id
    sign_in(create(:user, :super_admin))
    visit '/admin/notice'
    find('li.delete_member_link a').click
    find('button.btn-danger').click

    expect(current_path).to eq '/admin/notice'
    expect(Notice.where(id: orig_id)).to eq []
  end

  scenario 'token url links are clickable' do
    token_url = create(:token_url)
    sign_in(create(:user, :super_admin))
    visit '/admin/token_url'
    find('.token_url_row .url_field a').click
    expect(page.status_code).to be(200)
  end
end
