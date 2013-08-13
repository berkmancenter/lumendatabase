require 'spec_helper'

feature "typed notice submissions" do
  scenario "User submits and views a Trademark type notice" do
    submission = NoticeSubmissionOnPage.new(Trademark)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",
      "Mark" => "My trademark (TM)",
      "Infringing URL" => "http://example.com/infringing_url1",
      "Alleged Infringment" => "They used my thing",
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })

    submission.submit

    open_recent_notice

    expect(page).to have_content("Trademark - A title")
    within("#works") do
      expect(page).to have_content('Mark')
      expect(page).to have_content('My trademark (TM)')
    end
    within('.notice-body') do
      expect(page).to have_content('Alleged Infringment')
      expect(page).to have_content('They used my thing')
    end
  end

  scenario "User submits and views a Defamation type notice" do
    submission = NoticeSubmissionOnPage.new(Defamation)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",
      "Legal Complaint" => "They impuned upon my good character",
      "Defamatory URL" => "http://example.com/defamatory_url1",
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
      expect(page).to have_content('Defamatory URLs')
      expect(page).to have_content('http://example.com/defamatory_url1')
    end
    within('.notice-body') do
      expect(page).to have_content('Legal Complaint')
      expect(page).to have_content('They impuned upon my good character')
    end
  end
end
