require 'spec_helper'

feature "typed notice submissions" do
  scenario "User submits and views a Trademark notice" do
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

  scenario "User submits and views a Defamation notice" do
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
      expect(page).to have_content('Locations of Defamatory Material')
      expect(page).to have_content('http://example.com/defamatory_url1')
    end

    within('.notice-body') do
      expect(page).to have_content('Legal Complaint')
      expect(page).to have_content('They impuned upon my good character')
    end
  end

  scenario "User submits and views an International notice" do
    submission = NoticeSubmissionOnPage.new(International)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",

      "Subject of Complaint" => "I am English", # works.description
      "URL of original work" => "http://example.com/original_object1", # copyrighted_urls
      "Offending URL" => "http://example.com/offending_url1", # infringing_urls

      "Explanation of Complaint" => "I am wicked unhappy with the French", #notice.body
      "Relevant laws or regulations" => "USC foo bar 21"
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })
    submission.fill_in_entity_form_with(:principal, {
      'Name' => 'Principal Issuing Authority',
    })

    submission.submit

    open_recent_notice

    expect(page).to have_content("International - A title")

    within("#works") do
      expect(page).to have_content('Offending URLs')
      expect(page).to have_content('http://example.com/offending_url1')
      expect(page).to have_content('URLs of original work')
      expect(page).to have_content('http://example.com/original_object1')
    end

    within('.notice-body') do
      expect(page).to have_content('Explanation of complaint')
      expect(page).to have_content('I am wicked unhappy with the French')
      expect(page).to have_content('USC foo bar 21')
    end
  end

  scenario "User submits and views a CourtOrder notice" do
    submission = NoticeSubmissionOnPage.new(CourtOrder)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",

      "Subject of Court Order" => "My sweet website", # works.description
      "Targetted URL" => "http://example.com/targetted_url", # infringing_urls

      "Explanation of Court Order" => "I guess they don't like me", #notice.body
      "Relevant laws or regulations" => "USC foo bar 21"
    })

    %i|recipient sender principal issuing_court plaintiff defendant|.each do |role|
      submission.fill_in_entity_form_with(role, {
        'Name' => "#{role} entity",
      })
    end

    submission.submit

    open_recent_notice

    expect(page).to have_content("Court Order - A title")

    within("#works") do
      expect(page).to have_content('Targetted URLs')
      expect(page).to have_content('http://example.com/targetted_url')
    end

    within('.notice-body') do
      expect(page).to have_content('Explanation of Court Order')
      expect(page).to have_content("I guess they don't like me")
      expect(page).to have_content('USC foo bar 21')
    end
  end

  scenario "User submits and views a Law Enforcement Request notice" do
    submission = NoticeSubmissionOnPage.new(LawEnforcementRequest)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",

      "Subject of Enforcement Request" => "My Tiny Tim fansite", # works.description
      "URL of original work" => "http://example.com/original_object1", # copyrighted_urls
      "URL mentioned in request" => "http://example.com/offending_url1", # infringing_urls

      "Explanation of Law Enforcement Request" => "I don't get it. He made sick music.", #notice.body
      "Relevant laws or regulations" => "USC foo bar 21"
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })
    submission.fill_in_entity_form_with(:principal, {
      'Name' => 'Principal Issuing Authority',
    })

    submission.submit

    open_recent_notice

    expect(page).to have_content("Law Enforcement Request - A title")

    within("#works") do
      expect(page).to have_content('URLs mentioned in request')
      expect(page).to have_content('http://example.com/offending_url1')
      expect(page).to have_content('URLs of original work')
      expect(page).to have_content('http://example.com/original_object1')
      expect(page).to have_content("My Tiny Tim fansite")
    end

    within('.notice-body') do
      expect(page).to have_content('Explanation of Request')
      expect(page).to have_content("I don't get it. He made sick music.")
      expect(page).to have_content('USC foo bar 21')
    end
  end

  scenario "User submits and views a PrivateInformation notice" do
    submission = NoticeSubmissionOnPage.new(PrivateInformation)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",

      "Complaint" => "These URLs disclose my existence", # works.description
      "Original Work URL" => "http://example.com/original_object1", # copyrighted_urls
      "URL with private information" => "http://example.com/offending_url1", # infringing_urls

      "Explanation of Complaint" => "I am in witness protection", #notice.body
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })

    submission.submit

    open_recent_notice

    expect(page).to have_content("Private Information - A title")

    within("#works") do
      expect(page).to have_content('URLs with private information')
      expect(page).to have_content('http://example.com/offending_url1')
      expect(page).to have_content('URLs of original work')
      expect(page).to have_content('http://example.com/original_object1')
      expect(page).to have_content('These URLs disclose my existence')
    end

    within('.notice-body') do
      expect(page).to have_content('Explanation of complaint')
      expect(page).to have_content('I am in witness protection')
    end
  end

  scenario "User submits and views an Other notice" do
    submission = NoticeSubmissionOnPage.new(Other)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Title" => "A title",

      "Complaint" => "These URLs are a serious problem", # works.description
      "Original Work URL" => "http://example.com/original_object1", # copyrighted_urls
      "Problematic URL" => "http://example.com/offending_url1", # infringing_urls

      "Explanation of Complaint" => "I am complaining", #notice.body
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })

    submission.submit

    open_recent_notice

    expect(page).to have_content("Other - A title")

    within("#works") do
      expect(page).to have_content('Problematic URLs')
      expect(page).to have_content('http://example.com/offending_url1')
      expect(page).to have_content('URLs of original work')
      expect(page).to have_content('http://example.com/original_object1')
      expect(page).to have_content('These URLs are a serious problem')
    end

    within('.notice-body') do
      expect(page).to have_content('Explanation of complaint')
      expect(page).to have_content('I am complaining')
    end
  end
end
