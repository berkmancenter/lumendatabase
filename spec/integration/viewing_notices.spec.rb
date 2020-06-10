require 'rails_helper'

feature 'Viewing notices' do
  include NoticeActions

  before :all do
    @notice_title = 'A wonderful title'
    submit_recent_notice(@notice_title)
  end

  after :all do
    Notice.destroy_all
  end

  scenario 'as an anonymous user' do
    visit notice_url(Notice.last)

    check_notice_title

    check_limited_works_urls
  end

  scenario 'as an admin' do
    user = create(:user, :admin)
    sign_in(user)

    visit notice_url(Notice.last)

    check_notice_title

    check_full_works_urls
  end

  scenario 'as an anonymous user with a token for a wrong notice' do
    notice2 = create(:dmca)
    token_url = TokenUrl.create(
      email: 'user@example.com',
      notice: notice2,
      expiration_date: Time.now + 24.hours
    )

    visit notice_url(Notice.last, access_token: token_url.token)

    check_notice_title

    check_limited_works_urls
  end

  scenario 'as an anonymous user with a token' do
    token_url = TokenUrl.create(
      email: 'user@example.com',
      notice: Notice.last,
      expiration_date: Time.now + 24.hours
    )

    visit notice_url(Notice.last, access_token: token_url.token)

    check_notice_title

    check_full_works_urls
  end

  scenario 'as an anonymous user viewing allowed notice' do
    ENV['ALLOWED_NOTICES_FULL'] = "1234,#{Notice.last.id}"

    visit notice_url(Notice.last)

    check_full_works_urls
  end

  def check_full_works_urls
    within('#works') do
      expect(page).to have_content 'http://www.example.com/original_work.pdf'
      expect(page).not_to have_content 'example.com - 1 URL'
      expect(page).to have_content 'A series of videos and still images'
      expect(page).to have_css(
        %{.infringing_url:contains("http://example.com/infringing_url1")}
      )
    end
  end

  def check_limited_works_urls
    within('#works') do
      expect(page).to have_content 'example.com - 1 URL'
      expect(page).not_to have_content 'http://www.example.com/original_work.pdf'
      expect(page).to have_content 'A series of videos and still images'
    end
  end

  def check_notice_title
    within('.notice-show') do
      expect(page).to have_css('h1', text: @notice_title)
    end
  end
end
