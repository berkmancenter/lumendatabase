require 'rails_helper'

feature 'typed notice submissions' do
  scenario 'Non signed-in user cannot see new notice forms' do
    visit '/notices/new'

    expect(page).to have_words('Direct submission to Lumen is no longer available. If you are interested in sharing with Lumen copies of takedown notices you have sent or received, please contact Lumen.')
  end

  scenario 'User submits and views a Trademark notice' do
    submission = NoticeSubmissionOnPage.new(
      Trademark, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      'Mark' => 'My trademark (TM)',
      'Infringing URL' => 'http://example.com/infringing_url1',
      'Describe the alleged infringement' => 'They used my thing',
      'Registration Number' => '1337'
    )

    Trademark::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Trademark notice to Recipient')

    within('#works') do
      expect(page).to have_words('Description of allegedly infringed mark')
      expect(page).to have_words('My trademark (TM)')
    end

    within('.notice-body') do
      expect(page).to have_words('Alleged Infringement')
      expect(page).to have_words('They used my thing')
      expect(page).to have_words('1337')
    end
  end

  scenario 'User submits and views a Defamation notice' do
    submission = NoticeSubmissionOnPage.new(
      Defamation, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      'Legal Complaint' => 'They impugned my good character',
      'Allegedly Defamatory URL' => 'http://example.com/defamatory_url1'
    )

    Defamation::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Defamation notice to Recipient')

    within('#works') do
      expect(page).to have_words('URLs of Allegedly Defamatory Material')
      expect(page).to have_words('http://example.com/defamatory_url1')
    end

    within('.notice-body') do
      expect(page).to have_words('Legal Complaint')
      expect(page).to have_words('They impugned my good character')
    end
  end

  scenario 'User submits and views a Data Protection notice' do
    submission = NoticeSubmissionOnPage.new(
      DataProtection, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      'Legal Complaint' => 'I want to be forgotten',
      'URL mentioned in request' => 'http://example.com/defamatory_url1'
    )

    DataProtection::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Data Protection notice to Recipient')

    within('#works') do
      expect(page).to have_words(
        'Location of Some of the Material Requested for Removal'
      )
      expect(page).to have_words('http://example.com/defamatory_url1')
    end
  end

  scenario 'User submits and views a CourtOrder notice' do
    submission = NoticeSubmissionOnPage.new(
      CourtOrder, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      'Subject of Court Order' => 'My sweet website', # works.description
      'Targeted URL' => 'http://example.com/targeted_url', # infringing_urls
      'Explanation of Court Order' => "I guess they don't like me", # notice.body
      'Laws Referenced by Court Order' => 'USC foo bar 21'
    )

    CourtOrder::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Court Order notice to Recipient')

    within('#works') do
      expect(page).to have_words('Targeted URLs')
      expect(page).to have_words('http://example.com/targeted_url')
    end

    within('.notice-body') do
      expect(page).to have_words('Explanation of Court Order')
      expect(page).to have_words("I guess they don't like me")
      expect(page).to have_words('USC foo bar 21')
    end
  end

  scenario 'User submits and views a Law Enforcement Request notice' do
    submission = NoticeSubmissionOnPage.new(
      LawEnforcementRequest, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      'Subject of Enforcement Request' => 'My Tiny Tim fansite', # works.description
      'URL of original work' => 'http://example.com/original_object1', # copyrighted_urls
      'URL mentioned in request' => 'http://example.com/offending_url1', # infringing_urls
      'Explanation of Law Enforcement Request' => "I don't get it. He made sick music.", #notice.body
      'Relevant laws or regulations' => 'USC foo bar 21'
    )

    submission.choose('Civil Subpoena', :request_type)

    LawEnforcementRequest::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Law Enforcement Request notice to Recipient')

    within('#works') do
      expect(page).to have_words('URLs mentioned in request')
      expect(page).to have_words('http://example.com/offending_url1')
      expect(page).to have_words('URLs of original work')
      expect(page).to have_words('http://example.com/original_object1')
      expect(page).to have_words('My Tiny Tim fansite')
    end

    within('.notice-body') do
      expect(page).to have_words('Explanation of Request')
      expect(page).to have_words("I don't get it. He made sick music.")
      expect(page).to have_words('USC foo bar 21')
      expect(page).to have_words('Civil Subpoena')
    end

    within('#entities') do
      expect(page).to have_words('Principal')
    end
  end

  scenario 'User submits and views a PrivateInformation notice' do
    submission = NoticeSubmissionOnPage.new(
      PrivateInformation, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      'Type of information' => 'These URLs disclose my existence', # works.description
      'URL with private information' => 'http://example.com/offending_url1', # infringing_urls
      'Explanation of Complaint' => 'I am in witness protection', #notice.body
    )

    PrivateInformation::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Private Information notice to Recipient')

    within('#works') do
      expect(page).to have_words('URLs with private information')
      expect(page).to have_words('http://example.com/offending_url1')
      expect(page).to have_words('URLs of original work')
      expect(page).to have_words('These URLs disclose my existence')
    end

    within('.notice-body') do
      expect(page).to have_words('Explanation of complaint')
      expect(page).to have_words('I am in witness protection')
    end
  end

  scenario 'User submits and views an Other notice' do
    submission = NoticeSubmissionOnPage.new(Other, create(:user, :submitter))
    submission.open_submission_form

    submission.fill_in_form_with(
      'Complaint' => 'These URLs are a serious problem', # works.description
      'Original Work URL' => 'http://example.com/original_object1', # copyrighted_urls
      'Problematic URL' => 'http://example.com/offending_url1', # infringing_urls
      'Explanation of Complaint' => 'I am complaining', # notice.body
    )

    Other::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Other notice to Recipient')

    within('#works') do
      expect(page).to have_words('Problematic URLs')
      expect(page).to have_words('http://example.com/offending_url1')
      expect(page).to have_words('URLs of original work')
      expect(page).to have_words('http://example.com/original_object1')
      expect(page).to have_words('These URLs are a serious problem')
    end

    within('.notice-body') do
      expect(page).to have_words('Explanation of complaint')
      expect(page).to have_words('I am complaining')
    end
  end

  scenario 'Entities can have different default types depending on role' do
    submission = NoticeSubmissionOnPage.new(
      CourtOrder, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.within_entity_with_role('issuing_court') do
      expect(page).to have_select('Issuing Court Type',
                                  selected: 'organization')
    end

    submission.within_entity_with_role('sender') do
      expect(page).to have_select('Sender Type', selected: 'individual')
    end
  end
end
