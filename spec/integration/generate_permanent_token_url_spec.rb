require 'rails_helper'

feature 'permanent token url generation' do
  let(:notice) { create(:dmca) }

  scenario 'user with any role can see the generation link and can generate successfully', js: true do
    roles = %i[notice_viewer researcher redactor]

    roles.map { |role| test_permenent_token_urls_generation(create(:user, role, can_generate_permanent_notice_token_urls: true)) }
  end

  scenario 'user without access can\'t see the generation link', js: true do
    sign_in(
      create(:user, :notice_viewer, can_generate_permanent_notice_token_urls: false)
    )

    visit notice_path(notice)

    expect(page).not_to have_content 'Generate a permanent URL to the full version of this notice'
  end

  scenario 'user with access can see the generation link and can generate successfully', js: true do
    notice_viewer_with_can_generate_permanent_notice_token_urls = create(:user, :notice_viewer, can_generate_permanent_notice_token_urls: true)
    can_generate_permanent_notice_token_urls(notice_viewer_with_can_generate_permanent_notice_token_urls)

    researcher_with_can_generate_permanent_notice_token_urls = create(:user, :researcher, can_generate_permanent_notice_token_urls: true)
    can_generate_permanent_notice_token_urls(researcher_with_can_generate_permanent_notice_token_urls)

    admin = create(:user, :admin)
    can_generate_permanent_notice_token_urls(admin)

    super_admin = create(:user, :super_admin)
    can_generate_permanent_notice_token_urls(super_admin)
  end

  scenario 'user without access can\'t see the generation link', js: true do
    notice_viewer_without_can_generate_permanent_notice_token_urls = create(:user, :notice_viewer, can_generate_permanent_notice_token_urls: false)
    cant_see_generation_link(notice_viewer_without_can_generate_permanent_notice_token_urls)

    researcher_without_can_generate_permanent_notice_token_urls = create(:user, :researcher, can_generate_permanent_notice_token_urls: false)
    cant_see_generation_link(researcher_without_can_generate_permanent_notice_token_urls)

    submitter_with_can_generate_permanent_notice_token_urls = create(:user, :submitter, can_generate_permanent_notice_token_urls: true)
    cant_see_generation_link(submitter_with_can_generate_permanent_notice_token_urls)
  end

  def can_generate_permanent_notice_token_urls(user)
    sign_in(user)

    visit notice_path(notice)

    expect(page).not_to have_content 'Generate a permanent URL to the full version of this notice'
  end

  def cant_see_generation_link(user)
    sign_in(user)

    visit notice_path(notice)

    if page.has_selector?('#hide-first-time-visitor-content', visible: true)
      find('#hide-first-time-visitor-content').click
    end

    click_on 'Generate a permanent URL to the full version of this notice'

    expect(page).to have_content 'A permanent URL for this notice has been created'
  end
end
