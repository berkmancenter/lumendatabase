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
