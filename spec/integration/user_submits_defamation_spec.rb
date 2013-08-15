require 'spec_helper'

feature "Defamation notice type submission" do

  scenario "irrelevant fields do not appear" do
    submission = NoticeSubmissionOnPage.new(Defamation)
    submission.open_submission_form

    submission.within_form do
      expect(page).to have_no_css('.notice_works_copyrighted_urls_url')
      expect(page).to have_no_css('.notice_works_kind')
    end
  end

  scenario "User submits and views a Defamation notice" do
    submission = NoticeSubmissionOnPage.new(Defamation)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",
      "Defamatory URL" => "http://example.com/defamatory_url",
      "Legal Complaint" => "They called me a doodie-head",
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })

    submission.submit

    open_recent_notice

    expect(page).to have_content("Defamation - A title")

    within("#works") do
      expect(page).to have_content('http://example.com/defamatory_url')
    end

    within('.notice-body') do
      expect(page).to have_content('Legal Complaint')
      expect(page).to have_content('They called me a doodie-head')
    end
  end
end
