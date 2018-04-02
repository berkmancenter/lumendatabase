require 'rails_helper'
require 'support/notice_actions'

feature "Redactable fields" do
  include NoticeActions

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
      expect(page).to have_no_content(original_text)
    end

    context "Manual redaction" do
      scenario "Redacting selected text in #{field}", js: true do
        visit_redact_notice
        redactable_field = RedactableFieldOnPage.new(field)

        redactable_field.select_and_redact

        expect(page).to have_field("notice_#{field}", with: '[REDACTED]')
      end

      scenario "Restoring #{field} from original", js: true do
        notice = visit_redact_notice
        redactable_field = RedactableFieldOnPage.new(field)

        redactable_field.unredact

        expect(page).to have_field(
          "notice_#{field}",
          with: notice.send(:"#{field}_original")
        )
      end

      scenario "Publishing after review" do
        notice = visit_redact_notice

        uncheck 'Review required'
        click_on 'Save'

        visit "/notices/#{notice.id}"
        expect(page).to have_no_content(Notice::UNDER_REVIEW_VALUE)
      end

      private

      def visit_redact_notice
        user = create(:user, :admin)
        visit '/users/sign_in'
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        click_on "Log in"

        notice = create(:dmca, :redactable)

        visit "/admin/notice/#{notice.id}/redact_notice"

        notice
      end
    end
  end
end
