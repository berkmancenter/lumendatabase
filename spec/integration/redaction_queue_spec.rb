require 'spec_helper'

feature "Redaction queue" do
  scenario "A user processes their queue" do
    Redaction::Queue.stub(:queue_max).and_return(3)

    user = create(:user, :admin)
    notices = [
      create(:notice, :redactable),
      create(:notice, :redactable),
      notice_three = create(:notice, :redactable)
    ]

    queue = RedactionQueueOnPage.new
    queue.visit_as(user)
    queue.fill

    expect(queue).to have_notices(notices)

    # defaults all checked
    queue.unselect_notice(notice_three)
    queue.process_selected

    queue.publish_and_next

    expect(queue).not_to have_next

    queue.publish

    expect(queue).to have_notices([notice_three])
  end

  scenario "A user refills their queue by category and submitter" do
    user = create(:user, :admin)
    category_one = create(:category, name: "Cat 1")
    category_two = create(:category, name: "Cat 2")
    submitter = create(:entity, name: "Jim Smith")
    create(:notice) # not to be found
    expected_notices = [
      create(
        :notice,
        review_required: true,
        categories: [category_one],
        entity_notice_roles: [
          create(:entity_notice_role, name: 'submitter', entity: submitter)
        ]
      ),
      create(
        :notice,
        review_required: true,
        categories: [category_two],
        entity_notice_roles: [
          create(:entity_notice_role, name: 'submitter', entity: submitter)
        ]
      )
    ]

    queue = RedactionQueueOnPage.new
    queue.visit_as(user)

    queue.select_category_profile(category_one)
    queue.select_category_profile(category_two)
    queue.select_submitter_profile(submitter)
    queue.fill

    expect(queue).to have_notices(expected_notices)
  end

  scenario "A user redacts a pattern everywhere", js: true do
    user = create(:user, :admin)
    affected_notices = create_list(:notice, 3, :redactable, body: "Some text")
    unaffected_notices = create_list(:notice, 3, :redactable, body: "Some text")

    queue = RedactionQueueOnPage.new
    queue.visit_as(user)
    queue.fill

    unaffected_notices.each { |notice| queue.unselect_notice(notice) }

    queue.process_selected

    body_field = RedactableFieldOnPage.new(:body)
    body_field.select

    queue.redact_everywhere

    expect(body_field).to have_content('[REDACTED]')

    affected_notices.each do |notice|
      notice.reload
      expect(notice.body).to eq '[REDACTED]'
    end

    unaffected_notices.each do |notice|
      notice.reload
      expect(notice.body).to eq "Some text"
    end
  end
end
