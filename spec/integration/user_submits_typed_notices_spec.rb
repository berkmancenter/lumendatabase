require 'rails_helper'
require 'support/sign_in'

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

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Trademark notice to Recipient')

    within('#works') do
      expect(page).to have_words(Translation.t('notice_show_works_trademark_description'))
      expect(page).to have_words('My trademark (TM)')
    end

    within('.notice-body') do
      expect(page).to have_words(Translation.t('notice_show_works_alleged_infrigement'))
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

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Defamation notice to Recipient')

    within('#works') do
      expect(page).to have_content('URLs of Allegedly Defamatory Material')
      expect(page).to have_content('example.com - 1 URL')
    end

    sign_in(create(:user, :admin))

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_content("Defamation notice to Recipient")

    within("#works") do
      expect(page).to have_content('URLs of Allegedly Defamatory Material')
      expect(page).to have_content('http://example.com/defamatory_url1')
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
      Translation.t('notice_show_works_law_enf_gov_infringing_url_label') => 'http://example.com/defamatory_url1'
    )

    DataProtection::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Data Protection notice to Recipient')

    within("#works") do
      expect(page).to have_content('Location of Some of the Material Requested for Removal')
      expect(page).to have_content('example.com - 1 URL')
    end

    sign_in(create(:user, :admin))

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    within("#works") do
      expect(page).to have_content('http://example.com/defamatory_url1')
    end
  end

  scenario 'User submits and views a CourtOrder notice' do
    submission = NoticeSubmissionOnPage.new(
      CourtOrder, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      Translation.t('notice_new_court_works_description_label') => 'My sweet website', # works.description
      'Targeted URL' => 'http://example.com/targeted_url', # infringing_urls
      Translation.t('notice_show_court_body') => "I guess they don't like me", # notice.body
      Translation.t('notice_show_court_regulations_label') => 'USC foo bar 21'
    )

    CourtOrder::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Court Order notice to Recipient')

    within('.notice-body') do
      expect(page).to have_content(Translation.t('notice_show_court_body'))
      expect(page).to have_content("I guess they don't like me")
      expect(page).to have_content('USC foo bar 21')
    end

    within('#works') do
      expect(page).to have_content(Translation.t('notice_show_court_works_infringing_label'))
      expect(page).to have_content('example.com - 1 URL')
    end

    sign_in(create(:user, :admin))

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    within("#works") do
      expect(page).to have_content('http://example.com/targeted_url')
    end
  end

  scenario 'User submits and views a Law Enforcement Request notice' do
    submission = NoticeSubmissionOnPage.new(
      LawEnforcementRequest, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      Translation.t('notice_new_works_gov_law_enf_desc') => 'My Tiny Tim fansite', # works.description
      Translation.t('notice_show_works_law_enf_gov_copyrighted_url_label') => 'http://example.com/original_object1', # copyrighted_urls
      Translation.t('notice_show_works_law_enf_gov_infringing_url_label') => 'http://example2.com/offending_url1', # infringing_urls
      'Explanation of Law Enforcement Request' => "I don't get it. He made sick music.", #notice.body
      Translation.t('notice_new_works_gov_law_enf_regulations') => 'USC foo bar 21'
    )

    submission.choose('Civil Subpoena', :request_type)

    LawEnforcementRequest::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Law Enforcement Request notice to Recipient')

    within('#works') do
      expect(page).to have_content(Translation.t('notice_new_works_urls_mentioned'))
      expect(page).to have_content('example.com - 1 URL')
      expect(page).to have_content(Translation.t('notice_works_urls_of_original'))
      expect(page).to have_content('example2.com - 1 URL')
      expect(page).to have_content('My Tiny Tim fansite')
    end

    within('.notice-body') do
      expect(page).to have_words(Translation.t('notice_show_works_gov_law_enf_body'))
      expect(page).to have_words("I don't get it. He made sick music.")
      expect(page).to have_words('USC foo bar 21')
      expect(page).to have_words('Civil Subpoena')
    end

    within('#entities') do
      expect(page).to have_words('Principal')
    end

    sign_in(create(:user, :admin))

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    within("#works") do
      expect(page).to have_content('http://example2.com/offending_url1')
      expect(page).to have_content('http://example.com/original_object1')
    end
  end

  scenario 'User submits and views a PrivateInformation notice' do
    submission = NoticeSubmissionOnPage.new(
      PrivateInformation, create(:user, :submitter)
    )
    submission.open_submission_form

    submission.fill_in_form_with(
      Translation.t('notice_new_works_private_description') => 'These URLs disclose my existence', # works.description
      'URL with private information' => 'http://example.com/offending_url1', # infringing_urls
      Translation.t('notice_new_explanation') => 'I am in witness protection', #notice.body
    )

    PrivateInformation::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Private Information notice to Recipient')

    within('.notice-body') do
      expect(page).to have_content(Translation.t('notice_show_private_body'))
      expect(page).to have_content('I am in witness protection')
    end

    within('#works') do
      expect(page).to have_content(Translation.t('notice_works_private_urls'))
      expect(page).to have_content('example.com - 1 URL')
      expect(page).to have_content(Translation.t('notice_works_urls_of_original'))
      expect(page).to have_content('These URLs disclose my existence')
    end

    visit '/'

    sign_in(create(:user, :admin))

    within('#recent-notices li:nth-child(1)') { find('a').click }

    within("#works") do
      expect(page).to have_content('http://example.com/offending_url1')
    end
  end

  scenario 'User submits and views an Other notice' do
    submission = NoticeSubmissionOnPage.new(Other, create(:user, :submitter))
    submission.open_submission_form

    submission.fill_in_form_with(
      'Complaint' => 'These URLs are a serious problem', # works.description
      'Original Work URL' => 'http://example.com/original_object1', # copyrighted_urls
      'Problematic URL' => 'http://example2.com/offending_url1', # infringing_urls
      Translation.t('notice_new_explanation') => 'I am complaining', # notice.body
    )

    Other::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
    end

    submission.submit

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Other notice to Recipient')

    within('.notice-body') do
      expect(page).to have_content(Translation.t('notice_show_private_body'))
      expect(page).to have_content('I am complaining')
    end

    within('#works') do
      expect(page).to have_content(Translation.t('notice_show_works_problematic_urls'))
      expect(page).to have_content('example.com - 1 URL')
      expect(page).to have_content(Translation.t('notice_works_urls_of_original'))
      expect(page).to have_content('example2.com - 1 URL')
      expect(page).to have_content('These URLs are a serious problem')
    end

    sign_in(create(:user, :admin))

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    within("#works") do
      expect(page).to have_content('http://example2.com/offending_url1')
      expect(page).to have_content('http://example.com/original_object1')
    end
  end

  scenario 'User submits and views a Counterfeit notice' do
    submission = NoticeSubmissionOnPage.new(Counterfeit, create(:user, :submitter))
    submission.open_submission_form

    submission.fill_in_form_with(
      'Description' => 'These URLs are a serious problem', # works.description
      'Allegedly Infringing Counterfeit URL' => 'http://example.com/original_object1',
      'Body' => 'I am complaining', # notice.body
    )

    roles = Counterfeit::DEFAULT_ENTITY_NOTICE_ROLES
    countries = Hash[roles.zip(
      ['Anguilla', 'Antarctica', 'Bangladesh', 'Cocos (Keeling) Islands']
    )]

    roles.each do |role|
      submission.fill_in_entity_form_with(
        role,
        'Name' => role.capitalize
      )
      within("section.#{role}") do
        select countries[role], from: 'Country'
      end
    end

    submission.submit

    sign_out

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    expect(page).to have_words('Notice Type: Counterfeit')

    principal_country = ::CountrySelect::ISO_COUNTRIES_FOR_SELECT[
      countries['principal']
    ].upcase

    expect(page).to have_words("Jurisdictions #{principal_country}")

    within('.notice-body') do
      expect(page).to have_content('Body')
      expect(page).to have_content('I am complaining')
    end

    within('#works') do
      expect(page).to have_words(Translation.t('notice_show_counterfeit_works_infringing_label'))
      expect(page).to have_content('example.com - 1 URL')
      expect(page).to have_content('These URLs are a serious problem')
    end

    sign_in(create(:user, :admin))

    visit '/'

    within('#recent-notices li:nth-child(1)') { find('a').click }

    within("#works") do
      expect(page).to have_content('http://example.com/original_object1')
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
