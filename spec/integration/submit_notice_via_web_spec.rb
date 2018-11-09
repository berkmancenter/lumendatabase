require 'rails_helper'
require 'support/sign_in'
require 'support/notice_actions'

feature 'notice submission' do
  include NoticeActions

  scenario 'non signed-in user cannot submit notices' do
    visit '/notices/new?type=DMCA'

    expect(page).to have_words('Direct submission to Lumen is no longer available. If you are interested in sharing with Lumen copies of takedown notices you have sent or received, please contact Lumen.')
  end

  scenario 'submitting a notice with title' do
    submit_recent_notice('A title')

    expect(page).to have_css('#flash_notice')

    expect(page).to have_css('#recent-notices li', text: 'A title')
  end

  scenario 'submitting a notice with language' do
    submit_recent_notice do
      select 'en - English', from: 'Language'
    end

    notice = Notice.last
    expect(notice.language).to eq 'en'
  end

  scenario 'submitting a notice with action taken' do
    submit_recent_notice do
      select 'Yes', from: 'Action taken'
    end

    open_recent_notice

    expect(page).to have_words('Action taken: Yes')
  end

  scenario 'submitting a notice with a jurisdiction' do
    submit_recent_notice do
      fill_in 'Jurisdiction', with: 'US, foobar'
    end

    notice = Notice.last
    expect(notice.jurisdiction_list).to match_array %w[US foobar]
  end

  scenario 'submitting a notice with dates' do
    submit_recent_notice do
      fill_in 'Date sent', with: Time.zone.local(2013, 5, 4)
      fill_in 'Date received', with: Time.zone.local(2013, 5, 5)
    end

    open_recent_notice

    within('.recipient .date') do
      expect(page).to have_words('May 05, 2013')
    end

    within('.sender .date') do
      expect(page).to have_words('May 04, 2013')
    end
  end

  scenario 'attached documents default to type supporting' do
    submit_recent_notice { attach_notice }

    notice = Notice.last
    expect(notice).to have(0).original_documents
    expect(notice).to have(1).supporting_document
  end

  scenario 'submitting a notice with a document', js: true do
    submit_recent_notice do
      add_document
    end

    notice = Notice.last

    expect(notice).to have(1).supporting_document
  end

  scenario 'submitting a notice with multiple documents', js: true do
    submit_recent_notice do
      add_document
      add_document
      add_document
    end

    open_recent_notice

    within('ol.attachments') do
      expect(page).to have_css('li', count: 3)
    end
  end

  scenario 'submitting a notice with tags' do
    submit_recent_notice do
      fill_in 'Tag list', with: 'tag_1, tag_2'
    end

    open_recent_notice

    within('#tags') do
      expect(page).to have_words 'tag_1'
    end
  end

  scenario 'submitting a notice with topics' do
    create(:topic, name: 'Topic 1')
    create(:topic, name: 'Topic 2')
    create(:topic, name: 'Topic 3')

    submit_recent_notice do
      select 'Topic 1', from: 'Topics'
      select 'Topic 3', from: 'Topics'
    end

    open_recent_notice

    within('#topics') do
      expect(page).to have_words 'Topic 1'
      expect(page).to have_words 'Topic 3'
    end
  end

  scenario 'submitting a notice with entities' do
    submit_recent_notice do
      within('section.recipient') do
        fill_in 'Name', with: 'Recipient the first'
        fill_in 'Address Line 1', with: 'Recipient Line 1'
        fill_in 'Address Line 2', with: 'Recipient Line 2'
        fill_in 'City', with: 'Recipient City'
        fill_in 'State', with: 'MA'
        select 'United States', from: 'Country'
        select 'organization', from: 'Recipient Type'
      end

      within('section.sender') do
        fill_in 'Name', with: 'Sender the first'
        select 'organization', from: 'Sender Type'
      end
    end

    open_recent_notice

    within('#entities') do
      expect(page).to have_words 'Recipient the first'
      expect(page).to have_words '[Private]'
      expect(page).to have_words 'Recipient City'
      expect(page).to have_words 'MA'
      expect(page).to have_words 'US'

      expect(page).to have_words 'Sender the first'
    end

    notice = Notice.last

    expect(notice.recipient.kind).to eq('organization')
    expect(notice.sender.kind).to eq('organization')
    expect(notice.submitter.kind).to eq('individual')
  end

  scenario 'entity addresses are partially private' do
    submit_recent_notice do
      within('section.recipient') do
        fill_in 'Name', with: 'Recipient the first'
        fill_in 'Address Line 1', with: 'Recipient Line 1'
        fill_in 'Address Line 2', with: 'Recipient Line 2'
        select 'organization', from: 'Recipient Type'
      end

      within('section.sender') do
        fill_in 'Name', with: 'Sender the first'
        fill_in 'Address Line 1', with: 'Sender Line 1'
        fill_in 'Address Line 2', with: 'Sender Line 2'
      end
    end

    open_recent_notice

    within('#entities') do
      expect(page).to have_no_content 'Recipient Line 1'
      expect(page).to have_no_content 'Recipient Line 2'
      expect(page).to have_no_content 'Sender Line 1'
      expect(page).to have_no_content 'Sender Line 2'
      expect(page).to have_no_content 'organization'
    end
  end

  scenario 'submitting notices with duplicate items' do
    submit_recent_notice
    submit_recent_notice

    expect(Notice.count).to eq 2
    expect(Entity.count).to eq 4
    expect(Work.count).to eq 2
    expect(InfringingUrl.count).to eq 1
  end

  scenario "submitting a notice with works" do
    user = create(:user, :submitter)

    sign_in(user)

    submit_recent_notice do
      fill_in 'Work URL', with: 'http://www.example.com/original_work.pdf'
      fill_in 'Description', with: 'A series of videos and still images'
      fill_in 'Infringing URL', with: 'http://example.com/infringing_url1'
    end

    sign_out

    visit '/'

    open_recent_notice

    within('#works') do
      expect(page).to have_content 'example.com - 1 URL'
      expect(page).to have_content 'movie'
      expect(page).to have_content 'A series of videos and still images'
    end

    user = create(:user, :super_admin)

    sign_in(user)

    visit '/'

    open_recent_notice

    within('#works') do
      expect(page).to have_content 'http://www.example.com/original_work.pdf'
      expect(page).to have_content 'movie'
      expect(page).to have_content 'A series of videos and still images'
      expect(page).to have_css(
        %{.infringing_url:contains("http://example.com/infringing_url1")}
      )
    end
  end

  scenario 'submitting a notice with a source' do
    submit_recent_notice do
      fill_in 'Sent via', with: 'Arbitrary source'
    end

    open_recent_notice

    expect(page).to have_words 'Sent via: Arbitrary source'
  end

  scenario 'submitting a notice with a subject' do
    submit_recent_notice do
      fill_in 'Subject', with: 'Some subject'
    end

    open_recent_notice

    expect(page).to have_words 'Re: Some subject'
  end

  scenario 'a form articulates its required fields correctly' do
    sign_in(create(:user, :submitter))

    visit '/notices/new?type=DMCA'

    within('form#new_notice') do
      expect(page).to have_css("input##{works_copyrighted_url_id}:not(.required)")
      expect(page).to have_css('input#notice_date_received:not(.required)')
    end
  end

  scenario "submitting a notice without required fields present" do
    sign_in(create(:user, :submitter))

    visit '/notices/new?type=DMCA'

    click_on 'Submit'

    all("form .#{entity_name_class}").each do |elem|
      within(elem) { expect(page).to have_css('.error') }
    end
  end

  scenario 'government requests include submitter' do
    sign_in(create(:user, :submitter))

    visit '/notices/new?type=GovernmentRequest'

    expect(page).to have_text('Submitter of the Notice')
  end

  context 'template rendering' do
    scenario 'counternotice form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=Counternotice'

      expect(page).to have_words 'Provide us with information about the DMCA counternotice'
      expect(page).to have_css '#notice_counternotice_for_id'
      expect(page).not_to have_css '#notice_action_taken'
      expect(page).not_to have_css 'textarea#notice_body'
      expect(page).to have_css 'select#notice_body'

      check_all_sections_rendered(page)
    end

    scenario 'court order form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=CourtOrder'

      expect(page).to have_words 'Provide us with information about the Court Order'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Explanation of Court Order')
      expect(page).not_to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'data protection form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=DataProtection'

      expect(page).to have_words 'Provide us with information about the Data Protection takedown notice'
      expect(page).to have_css '#notice_action_taken'
      expect(page).not_to have_css '#notice_subject'
      expect(page).not_to have_css '#notice_topic_ids'
      expect(page).not_to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Legal Complaint')
      expect(page).not_to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'defamation form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=Defamation'

      expect(page).to have_words 'Provide us with information about the Defamation takedown notice'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Legal Complaint')
      expect(page).not_to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'DMCA form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=DMCA'

      expect(page).to have_words 'Provide us with information about the DMCA takedown notice'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Body')
      expect(page).not_to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'government request form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=GovernmentRequest'

      expect(page).to have_words 'Provide us with information about the Government Request'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Explanation of Government Request')
      expect(page).to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'law enforcement request form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=LawEnforcementRequest'

      expect(page).to have_words 'Provide us with information about the Law Enforcement Request'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Explanation of Law Enforcement Request')
      expect(page).to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'other notice type form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=Other'

      expect(page).to have_words 'Provide us with information about the notice'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Explanation of Complaint')
      expect(page).not_to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'private information form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=PrivateInformation'

      expect(page).to have_words 'Provide us with information about the Private Information notice'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Explanation of Complaint')
      expect(page).not_to have_css '#notice_request_type'
      expect(page).not_to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end

    scenario 'trademark form' do
      sign_in(create(:user, :submitter))
      visit '/notices/new?type=Trademark'

      expect(page).to have_words 'Provide us with information about the Trademark takedown notice'
      expect(page).to have_css '#notice_action_taken'
      expect(page).to have_css '#notice_subject'
      expect(page).to have_css '#notice_topic_ids'
      expect(page).to have_css '#notice_tag_list'
      expect(page).not_to have_css 'select#notice_body'
      expect(page).to have_css('textarea#notice_body')
      expect(page).to have_css('.notice_body label',
                               text: 'Describe the alleged infringement of trademark')
      expect(page).not_to have_css '#notice_request_type'
      expect(page).to have_css '#notice_mark_registration_number'

      check_all_sections_rendered(page)
    end
  end

  private

  def works_copyrighted_url_id
    'notice_works_attributes_0_copyrighted_urls_attributes_0_url'
  end

  def entity_name_class
    'notice_entity_notice_roles_entity_name'
  end

  def check_all_sections_rendered(page)
    expect(page).to have_css '.body-wrapper.left.main'
    expect(page).to have_css '.body-wrapper.right.attach'
    expect(page).to have_css 'header'
    expect(page).to have_css '.role'
    expect(page).to have_css '.submit'
  end
end
