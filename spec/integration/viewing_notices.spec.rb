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

  scenario 'as an anonymous user viewing safelisted notice' do
    ENV['SAFELISTED_NOTICES_FULL'] = "1234,#{Notice.last.id}"

    visit notice_url(Notice.last)

    check_full_works_urls
  end

  context 'entities' do
    scenario 'can see the date when the sender is redacted' do
      n = Notice.last
      n.update(date_sent: Date.new(2020, 9, 2))
      n.reload
      allow(n).to receive(:hide_identities?).and_return(true)

      visit notice_url(n)

      expect(page).to have_content('Sent on September 02, 2020')
    end

    scenario 'blank addresses do not lead to lines of commas' do
      n = Notice.last
      n.submitter.update(city: '', state: '', zip: '', country_code: '')
      n.reload

      visit notice_url(n)

      expect(page).not_to have_content(',,,')
    end
  end

  context 'requesting additional access' do
    scenario 'notice is safelisted' do
      ENV['SAFELISTED_NOTICES_FULL'] = "1234,#{Notice.last.id}"

      visit notice_url(Notice.last)

      expect(page).not_to have_content('Click here to request access')
    end

    scenario 'confidential court orders' do
      n = Notice.last
      n.reset_type = 'CourtOrder'
      n.update(subject: "Google received a request to remove content from our services based on a court order. Due to the nature of the court's order, Google has not provided a copy to Lumen.")
      n.save
      n

      visit notice_url(n)

      expect(page).not_to have_content('Click here to request access')
    end
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
