require 'spec_helper'

feature "Redaction queue" do
  scenario "A user processes their queue" do
    Redaction::Queue.stub(:queue_max).and_return(3)

    user = create(:user)
    notices = [
      notice_one = create(:notice, :redactable),
      notice_two = create(:notice, :redactable),
      notice_three = create(:notice, :redactable)
    ]

    queue = QueueOnPage.new
    queue.visit_as(user)
    queue.fill

    expect(queue).to have_notices(notices)

    queue.select_notice(notice_one)
    queue.select_notice(notice_two)
    queue.process_selected

    queue.publish_and_next

    expect(queue).not_to have_next

    queue.publish

    expect(queue).to have_notices([notice_three])
  end

  scenario "A user refills their queue by category and submitter" do
    user = create(:user)
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

    queue = QueueOnPage.new
    queue.visit_as(user)

    queue.select_category_profile(category_one)
    queue.select_category_profile(category_two)
    queue.select_submitter_profile(submitter)
    queue.fill

    expect(queue).to have_notices(expected_notices)
  end

  class QueueOnPage < PageObject
    def visit_as(user)
      visit '/users/sign_in'
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Sign in"

      visit "/admin/notice/redact_queue"
    end

    def fill
      within_profiles { click_on 'Fill' }
    end

    def select_category_profile(category)
      select category.name, from: "In categories"
    end

    def select_submitter_profile(entity)
      select entity.name, from: "Submitted by"
    end

    def has_notices?(notices)
      actual_ids = page.all(".queue_item").map { |element| element[:id] }
      expected_ids = notices.map { |notice| "notice_#{notice.id}" }

      actual_ids.sort == expected_ids.sort
    end

    def select_notice(notice)
      within("tr#notice_#{notice.id}") { check "selected[]" }
    end

    def process_selected
      click_on 'Process selected'
    end

    def publish_and_next
      uncheck 'Review required'
      click_on 'Save and next'
    end

    def publish
      uncheck 'Review required'
      click_on 'Save'
    end

    def has_next?
      has_css?("input[value='Save and next']")
    end

    private

    def within_profiles(&block)
      within('#refill-queue', &block)
    end
  end
end
