require 'spec_helper'

feature "Redaction queue" do
  scenario "A user processes their queue" do
    Redaction::Queue.stub(:queue_max).and_return(2)

    user = create(:user)
    notice_one = create(:notice, :redactable)
    notice_two = create(:notice, :redactable)
    notice_three = create(:notice, :redactable)

    queue = QueueOnPage.new
    queue.visit_as(user)

    expect(queue).to have_notices([notice_one, notice_two])

    queue.select_notice(notice_one)
    queue.select_notice(notice_two)
    queue.process_selected

    queue.publish_and_next

    expect(queue).not_to have_next

    queue.publish

    expect(queue).to have_notices([notice_three])
  end

  class QueueOnPage < PageObject
    def visit_as(user)
      visit '/users/sign_in'
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Sign in"

      visit "/admin/notice/redact_queue"
    end

    def has_notices?(notices)
      actual_ids = page.all(".queue_item").map { |element| element[:id] }
      expected_ids = notices.map { |notice| "notice_#{notice.id}" }

      actual_ids == expected_ids
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
  end
end

feature "Redactable fields" do
  Notice::REDACTABLE_FIELDS.each do |field|

    scenario "#{field} is automatically redacted of phone numbers" do
      original_text = <<-EOT
        Please contact my laywer at (123) 456-7890 or, if
        you prefer I can be reached at 098-765-4321. In
        case it's useful, my mother's phone number is
        234.234.2345.
      EOT
      redacted_text = <<-EOT
        Please contact my laywer at [REDACTED] or, if
        you prefer I can be reached at [REDACTED]. In
        case it's useful, my mother's phone number is
        [REDACTED].
      EOT

      submit_recent_notice do
        fill_in "notice_#{field}", with: original_text
      end

      open_recent_notice
      expect(page).to have_content(redacted_text)
      expect(page).to_not have_content(original_text)
    end

    context "Manual redaction" do
      before { FakeWeb.allow_net_connect = true }

      scenario "Redacting selected text in #{field}", js: true do
        visit_redact_notice
        redactable_field = RedactableFieldOnPage.new(field)

        redactable_field.select_and_redact

        expect(redactable_field).to have_content('[REDACTED]')
      end

      scenario "Restoring #{field} from original", js: true do
        notice = visit_redact_notice
        redactable_field = RedactableFieldOnPage.new(field)

        redactable_field.unredact

        expect(redactable_field).to have_content(
          notice.send(:"#{field}_original")
        )
      end

      scenario "Publishing after review" do
        notice = visit_redact_notice

        uncheck 'Review required'
        click_on 'Save'

        visit "/notices/#{notice.id}"
        expect(page).not_to have_content(Notice::UNDER_REVIEW_VALUE)
      end

      private

      def visit_redact_notice
        user = create(:user)
        visit '/users/sign_in'
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        click_on "Sign in"

        notice = create(:notice, :redactable)

        visit "/admin/notice/#{notice.id}/redact_notice"

        notice
      end

      class RedactableFieldOnPage < PageObject
        def initialize(name)
          @name = name
        end

        def unredact
          page.find("#notice_#{@name}").click

          click_on "Unredact selected field"
        end

        def select_and_redact
          page.execute_script <<-EOS
            document.getElementById('notice_#{@name}').focus();
            document.getElementById('notice_#{@name}').select();
          EOS

          click_on 'Redact selected text'
        end

        def has_content?(content)
          page.find("#notice_#{@name}").value == content
        end

      end
    end

  end
end
