require_relative '../page_object'

class RedactionQueueOnPage < PageObject
  def visit_as(user)
    visit '/users/sign_in'
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_on "Sign in"

    visit "/admin/notice/redact_queue"
  end

  def fill
    within_profiles { click_on 'Fill Queue' }
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

  def unselect_notice(notice)
    within("tr#notice_#{notice.id}") { uncheck "selected[]" }
  end

  def process_selected
    click_on 'Process selected'
  end

  def redact_everywhere
    page.execute_script 'window.original_confirm = window.confirm'
    page.execute_script 'window.confirm = function(msg) { return true; }'

    click_on 'Redact selection everywhere'
  ensure
    page.execute_script 'window.confirm = window.original_confirm'
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
