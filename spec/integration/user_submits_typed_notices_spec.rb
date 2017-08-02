require 'rails_helper'

feature "typed notice submissions" do
  scenario "User submits and views a Trademark notice" do
    submission = NoticeSubmissionOnPage.new(Trademark)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Mark" => "My trademark (TM)",
      "Infringing URL" => "http://example.com/infringing_url1",
      "Describe the alleged infringement" => "They used my thing",
      "Registration Number" => '1337'
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Trademark notice to Recipient")

    within("#works") do
      expect(page).to have_content('Description of allegedly infringed mark')
      expect(page).to have_content('My trademark (TM)')
    end

    within('.notice-body') do
      expect(page).to have_content('Alleged Infringement')
      expect(page).to have_content('They used my thing')
      expect(page).to have_content('1337')
    end
  end

  scenario "User submits and views a Defamation notice" do
    submission = NoticeSubmissionOnPage.new(Defamation)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Legal Complaint" => "They impuned upon my good character",
      "Allegedly Defamatory URL" => "http://example.com/defamatory_url1",
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    submission.fill_in_entity_form_with(:sender, {
      'Name' => 'Sender',
    })

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Defamation notice to Recipient")

    within("#works") do
      expect(page).to have_content('URLs of Allegedly Defamatory Material')
      expect(page).to have_content('http://example.com/defamatory_url1')
    end

    within('.notice-body') do
      expect(page).to have_content('Legal Complaint')
      expect(page).to have_content('They impuned upon my good character')
    end
  end
  
  scenario "User submits and views a Data Protection notice" do
    submission = NoticeSubmissionOnPage.new(DataProtection)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Legal Complaint" => "I want to be forgotten",
      "URL mentioned in request" => "http://example.com/defamatory_url1",
    })

    submission.fill_in_entity_form_with(:recipient, {
      'Name' => 'Recipient',
    })
    #submission.fill_in_entity_form_with(:sender, {
    #  'Name' => 'Sender',
    #})

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Data Protection notice to Recipient")

    within("#works") do
      expect(page).to have_content('Location of Some of the Material Requested for Removal')
      expect(page).to have_content('http://example.com/defamatory_url1')
    end

    #within('.notice-body') do
    #  expect(page).to have_content('Legal Complaint')
    #  expect(page).to have_content('I want to be forgotten')
    #end
  end

  scenario "User submits and views a CourtOrder notice" do
    submission = NoticeSubmissionOnPage.new(CourtOrder)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Subject of Court Order" => "My sweet website", # works.description
      "Targeted URL" => "http://example.com/targeted_url", # infringing_urls

      "Explanation of Court Order" => "I guess they don't like me", #notice.body
      "Laws Referenced by Court Order" => "USC foo bar 21"
    })

    %i|recipient sender principal issuing_court plaintiff defendant|.each do |role|
      submission.fill_in_entity_form_with(role, {
        'Name' => role.capitalize
      })
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Court Order notice to Recipient")

    within("#works") do
      expect(page).to have_content('Targeted URLs')
      expect(page).to have_content('http://example.com/targeted_url')
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
      "Subject of Enforcement Request" => "My Tiny Tim fansite", # works.description
      "URL of original work" => "http://example.com/original_object1", # copyrighted_urls
      "URL mentioned in request" => "http://example.com/offending_url1", # infringing_urls

      "Explanation of Law Enforcement Request" => "I don't get it. He made sick music.", #notice.body
      "Relevant laws or regulations" => "USC foo bar 21",
    })

    submission.choose('Civil Subpoena', :request_type)

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

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Law Enforcement Request notice to Recipient")

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
      expect(page).to have_content('Civil Subpoena')
    end

    within('#entities') do
      expect(page).to have_content('Principal Issuing Authority')
    end
  end

  scenario "User submits and views a PrivateInformation notice" do
    submission = NoticeSubmissionOnPage.new(PrivateInformation)
    submission.open_submission_form

    submission.fill_in_form_with({
      "Type of information" => "These URLs disclose my existence", # works.description
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

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Private Information notice to Recipient")

    within("#works") do
      expect(page).to have_content('URLs with private information')
      expect(page).to have_content('http://example.com/offending_url1')
      expect(page).to have_content('URLs of original work')
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

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Other notice to Recipient")

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

  scenario "Entities can have different default types depending on role" do
    submission = NoticeSubmissionOnPage.new(CourtOrder)
    submission.open_submission_form

    submission.within_entity_with_role('issuing_court') do
      expect(page).to have_select('Issuing Court Type', selected: 'organization')
    end

    submission.within_entity_with_role('sender') do
      expect(page).to have_select('Sender Type', selected: 'individual')
    end
  end

end
