require 'spec_helper'

feature "Auto-redaction" do
  scenario "Legal (Other) is automatically redacted of phone numbers" do
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
      fill_in "Legal (Other)", with: original_text
    end

    open_recent_notice
    expect(page).to have_content(redacted_text)
    expect(page).to_not have_content(original_text)
  end
end

feature "Manual redaction" do
  before { FakeWeb.allow_net_connect = true }

  scenario "Redacting selection", js: true do
    visit_redact_notice
    redactable_field = RedactableFieldOnPage.new(:legal_other)

    redactable_field.select_and_redact

    expect(redactable_field).to have_content('[REDACTED]')
  end

  scenario "Restoring from original", js: true do
    notice = visit_redact_notice
    redactable_field = RedactableFieldOnPage.new(:legal_other)

    redactable_field.unredact

    expect(redactable_field).to have_content(notice.legal_other_original)
  end


  private

  def visit_redact_notice
    user = create(:user)
    visit '/users/sign_in'
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_on "Sign in"

    notice = create(
      :notice,
      legal_other: "Some sensitive text",
      legal_other_original: "Some [REDACTED] text"
    )

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
        document.getElementById('notice_legal_other').focus();
        document.getElementById('notice_legal_other').select();
      EOS

      click_on 'Redact selected text'
    end

    def has_content?(content)
      page.find("#notice_#{@name}").value == content
    end
  end
end
