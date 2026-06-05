class AddEnterpriseEmailTranslations < ActiveRecord::Migration[7.2]
  # Editable copy for the enterprise registration emails. Interpolation uses
  # Ruby's `format` with %{named} placeholders, matching the existing
  # Translation.t convention elsewhere in the app.
  TRANSLATIONS = {
    'enterprise_email_admin_notification_subject' => {
      notes: 'Admin email subject sent on each enterprise registration. Vars: %{company_name}.',
      body: 'New Lumen Enterprise registration: %{company_name}'
    },
    'enterprise_email_admin_notification_text' => {
      notes: 'Admin email (text). Vars: %{company_name} %{user_email} %{payment_method} %{plan} %{paid_until} %{company_contact_information} %{representative_contact_information}.',
      body: <<~TEXT
        A new Lumen Enterprise registration was submitted.

        Company name: %{company_name}
        User email: %{user_email}
        Payment method: %{payment_method}
        Plan: %{plan}
        Paid until: %{paid_until}

        Company contact information:
        %{company_contact_information}

        Representative contact information:
        %{representative_contact_information}
      TEXT
    },
    'enterprise_email_admin_notification_html' => {
      notes: 'Admin email (HTML). Vars: %{company_name} %{user_email} %{payment_method} %{plan} %{paid_until} %{company_contact_information} %{representative_contact_information}.',
      body: <<~HTML
        <h1>New Lumen Enterprise registration</h1>

        <table>
          <tr><th align="left">Company name</th><td>%{company_name}</td></tr>
          <tr><th align="left">User email</th><td>%{user_email}</td></tr>
          <tr><th align="left">Payment method</th><td>%{payment_method}</td></tr>
          <tr><th align="left">Plan</th><td>%{plan}</td></tr>
          <tr><th align="left">Paid until</th><td>%{paid_until}</td></tr>
        </table>

        <h2>Company contact information</h2>
        %{company_contact_information}

        <h2>Representative contact information</h2>
        %{representative_contact_information}
      HTML
    },
    'enterprise_email_client_confirmation_subject' => {
      notes: 'Client registration confirmation email subject.',
      body: 'Your Lumen Enterprise registration'
    },
    'enterprise_email_client_confirmation_pro_text' => {
      notes: 'Client confirmation (text) for credit-card/Pro registrations. Vars: %{company_name} %{payment_method} %{my_notices_url} %{settings_url}.',
      body: <<~TEXT
        Hi,

        Thanks for registering %{company_name} for Lumen Enterprise. We have received your registration.

        Selected payment method: %{payment_method}

        Your Pro access is ready. You can start working with the notices involving your verified domains right away:

        My notices: %{my_notices_url}
        Settings:   %{settings_url}

        Thanks,
        The Lumen team
      TEXT
    },
    'enterprise_email_client_confirmation_pro_html' => {
      notes: 'Client confirmation (HTML) for credit-card/Pro registrations. Vars: %{company_name} %{payment_method} %{my_notices_url} %{settings_url}.',
      body: <<~HTML
        <h1>Welcome to Lumen Enterprise</h1>

        <p>Thanks for registering <strong>%{company_name}</strong> for Lumen Enterprise. We have received your registration.</p>

        <p>Selected payment method: <strong>%{payment_method}</strong></p>

        <p>Your Pro access is ready. You can start working with the notices involving your verified domains right away:</p>
        <ul>
          <li><a href="%{my_notices_url}">My notices</a></li>
          <li><a href="%{settings_url}">Settings</a></li>
        </ul>

        <p>Thanks,<br>The Lumen team</p>
      HTML
    },
    'enterprise_email_client_confirmation_invoice_text' => {
      notes: 'Client confirmation (text) for invoice/inactive registrations. Vars: %{company_name} %{payment_method}.',
      body: <<~TEXT
        Hi,

        Thanks for registering %{company_name} for Lumen Enterprise. We have received your registration.

        Selected payment method: %{payment_method}

        We will follow up with you shortly about invoicing. Your Pro features unlock once payment has been processed.

        Until then, My notices, settings, notice reports, and API access are unavailable.

        Thanks,
        The Lumen team
      TEXT
    },
    'enterprise_email_client_confirmation_invoice_html' => {
      notes: 'Client confirmation (HTML) for invoice/inactive registrations. Vars: %{company_name} %{payment_method}.',
      body: <<~HTML
        <h1>Welcome to Lumen Enterprise</h1>

        <p>Thanks for registering <strong>%{company_name}</strong> for Lumen Enterprise. We have received your registration.</p>

        <p>Selected payment method: <strong>%{payment_method}</strong></p>

        <p>We will follow up with you shortly about invoicing. Your Pro features unlock once payment has been processed.</p>

        <p>Until then, My notices, settings, notice reports, and API access are unavailable.</p>

        <p>Thanks,<br>The Lumen team</p>
      HTML
    },
    'enterprise_email_invoice_accepted_subject' => {
      notes: 'Subject of the email sent when an admin accepts an invoice and activates the account.',
      body: 'Your Lumen Enterprise access is ready'
    },
    'enterprise_email_invoice_accepted_text' => {
      notes: 'Invoice-accepted email (text). Vars: %{company_name} %{paid_until} %{login_url} %{my_notices_url}.',
      body: <<~TEXT
        Hi,

        Good news - we've accepted the invoice for %{company_name} and your Lumen Enterprise Pro access is now active.

        Your Pro access is paid through %{paid_until}.

        You can log in and start using it right now:

        Log in:     %{login_url}
        My notices: %{my_notices_url}

        Thanks,
        The Lumen team
      TEXT
    },
    'enterprise_email_invoice_accepted_html' => {
      notes: 'Invoice-accepted email (HTML). Vars: %{company_name} %{paid_until} %{login_url} %{my_notices_url}.',
      body: <<~HTML
        <h1>Your Lumen Enterprise access is ready</h1>

        <p>Good news - we've accepted the invoice for <strong>%{company_name}</strong> and your Lumen Enterprise Pro access is now active.</p>

        <p>Your Pro access is paid through <strong>%{paid_until}</strong>.</p>

        <p>You can log in and start using it right now:</p>
        <ul>
          <li><a href="%{login_url}">Log in</a></li>
          <li><a href="%{my_notices_url}">My notices</a></li>
        </ul>

        <p>Thanks,<br>The Lumen team</p>
      HTML
    }
  }.freeze

  def up
    TRANSLATIONS.each do |key, attrs|
      Translation.find_or_create_by!(key: key) do |translation|
        translation.body = attrs[:body]
        translation.notes = attrs[:notes]
      end
    end
  end

  def down
    Translation.where(key: TRANSLATIONS.keys).delete_all
  end
end
