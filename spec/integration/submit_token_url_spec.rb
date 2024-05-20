require 'rails_helper'

feature 'token url submission' do
  let(:notice) { create(:dmca) }

  scenario 'submits successfully', js: true do
    visit request_access_notice_path(notice)

    expect_correct_title

    submit

    expect(page).to have_content 'A new single-use link has been generated and sent to'
  end

  scenario "won't allow to submit twice using the same email", js: true do
    visit request_access_notice_path(notice)

    expect_correct_title

    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip) { '1.1.1.1' }

    submit

    expect(page).to have_content 'A new single-use link has been generated and sent to'

    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip) { '2.2.2.2' }

    submit

    expect(page).to have_content 'This email address has been used already'
  end

  scenario 'will allow to submit twice using the same email when previous token are expired', js: true do
    visit request_access_notice_path(notice)

    expect_correct_title

    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip) { '1.1.1.1' }

    submit

    expect(page).to have_content 'A new single-use link has been generated and sent to'

    token_url = TokenUrl.last
    token_url.expiration_date = Time.now - LumenSetting.get_i('truncation_token_urls_active_period').seconds - 10.seconds
    token_url.save!

    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip) { '2.2.2.2' }

    submit

    expect(page).to have_content 'A new single-use link has been generated and sent to'
  end

  scenario "won't allow to submit using a not valid email", js: true do
    visit request_access_notice_path(notice)

    expect_correct_title

    submit('hohoho')
    message = page.find('#token_url_email').native.attribute('validationMessage')

    expect(message).to be_present
    expect(current_path).to eq request_access_notice_path(notice)
  end

  scenario 'will contain all the form fields', js: true do
    visit request_access_notice_path(notice)

    expect(page).to have_content 'Email address'
  end

  private

  def submit(email = 'user@example.com')
    fill_in 'Email', with: email
    click_on 'Submit'
  end

  def expect_correct_title
    expect(page).to have_content notice.title
  end
end
