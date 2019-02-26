require 'rails_helper'

feature 'Downloading documents' do
  let(:notice) { create(:dmca, :with_pdf, :with_image, :with_document) }
  let(:token_url) { create(:token_url, notice: notice, documents_notification: true) }

  scenario 'will redirect to the root page when a user has no access to download a document', js: true do
    visit notice.file_uploads.first.url

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('You are not allowed to download this document.')
  end

  scenario 'will download a document for a user with access', js: true do
    sign_in(create(:user, :admin))

    visit notice.file_uploads.first.url

    expect(page.response_headers['Content-Type']).to include('application/pdf')
  end

  scenario 'will disable a document notification for a user with a correct token', js: true do
    visit disable_documents_notification_token_url_path(token_url, token: token_url.token)

    expect(TokenUrl.last.documents_notification).to eq(false)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Documents notification has been disabled.')
  end

  scenario 'won\'t disable a document notification for a user with a wrong token', js: true do
    visit disable_documents_notification_token_url_path(token_url, token: 'hacky-token')

    expect(TokenUrl.last.documents_notification).to eq(true)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Wrong token provided.')
  end

  scenario 'won\'t disable a document notification for a non-exisiting token url', js: true do
    token_url.destroy

    visit disable_documents_notification_token_url_path(token_url, token: 'hohoho')

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Token url was not found.')
  end
end
