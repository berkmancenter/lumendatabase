require 'spec_helper'

feature "Redaction queue" do
  scenario "A user processes their queue" do
    notices = [
      create(:dmca, :redactable),
      create(:dmca, :redactable),
      notice = create(:dmca, :redactable)
    ]

    with_queue do |queue|
      expect(queue).to have_notices(notices)

      # defaults all checked
      queue.unselect_notice(notice)
      queue.process_selected

      queue.publish_and_next

      expect(queue).to have_no_next

      queue.publish

      expect(queue).to have_notices([notice])
    end
  end

  scenario "A user releases some of the notices in their queue" do
    create_list(:dmca, 2, :redactable)
    notice = create(:dmca, :redactable)

    with_queue do |queue|
      queue.unselect_notice(notice)
      queue.release_selected

      expect(queue).to have_notices([notice])
    end
  end

  scenario "A user marks some notices as spam" do
    notice_one = create(:dmca, :redactable)
    notice_two = create(:dmca, :redactable)
    notice_three = create(:dmca, :redactable)

    with_queue do |queue|
      queue.unselect_notice(notice_three)
      queue.mark_selected_as_spam

      expect(queue).to have_notices([notice_three])

      expect(notice_one.reload).to be_spam
      expect(notice_two.reload).to be_spam
      expect(notice_three.reload).not_to be_spam
    end
  end

  scenario "A user hides some notices" do
    notice_one = create(:dmca, :redactable)
    notice_two = create(:dmca, :redactable)
    notice_three = create(:dmca, :redactable)

    with_queue do |queue|
      queue.unselect_notice(notice_three)
      queue.hide_selected

      expect(queue).to have_notices([notice_three])

      expect(notice_one.reload).to be_hidden
      expect(notice_two.reload).to be_hidden
      expect(notice_three.reload).not_to be_hidden
    end
  end

  scenario "A user refills their queue by topic and submitter" do
    user = create(:user, :admin)
    topic_one = create(:topic, name: "Topic 1")
    topic_two = create(:topic, name: "Topic 2")
    submitter = create(:entity, name: "Jim Smith")
    create(:dmca) # not to be found
    expected_notices = [
      create(
        :dmca,
        review_required: true,
        topics: [topic_one],
        entity_notice_roles: [
          create(:entity_notice_role, name: 'submitter', entity: submitter)
        ]
      ),
      create(
        :dmca,
        review_required: true,
        topics: [topic_two],
        entity_notice_roles: [
          create(:entity_notice_role, name: 'submitter', entity: submitter)
        ]
      )
    ]

    queue = RedactionQueueOnPage.new
    queue.visit_as(user)

    queue.select_topic_profile(topic_one)
    queue.select_topic_profile(topic_two)
    queue.select_submitter_profile(submitter)
    queue.fill

    expect(queue).to have_notices(expected_notices)
  end

  scenario "A user redacts a pattern everywhere", js: true do
    affected_notices = create_list(:dmca, 3, :redactable, body: "Some text")
    unaffected_notices = create_list(:dmca, 3, :redactable, body: "Some text")

    with_queue do |queue|
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

  private

  def with_queue
    user = create(:user, :admin)

    queue = RedactionQueueOnPage.new
    queue.visit_as(user)
    queue.fill

    yield(queue) if block_given?

    queue
  end

end
