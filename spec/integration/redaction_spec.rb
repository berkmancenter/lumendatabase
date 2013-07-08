require 'spec_helper'

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

      class RedactableFieldOnPage
        include Capybara::DSL

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
