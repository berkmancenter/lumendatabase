class AddEnterpriseRegistrationWorkflowTranslations < ActiveRecord::Migration[7.2]
  # Editable copy for the reviewed enterprise sign-up: admin review request,
  # applicant acknowledgement, rejection, the confirm-email/set-password message,
  # and the admin notifications on email confirmation and payment. Interpolation
  # uses Ruby's `format` with %{named} placeholders, matching Translation.t
  # elsewhere in the app.
  TRANSLATIONS = {
    # --- Admin: a new registration needs review -----------------------------
    'enterprise_email_admin_review_request_subject' => {
      notes: 'Admin email subject for a new enterprise registration awaiting review. Vars: %{company_name}.',
      body: 'New Lumen Enterprise registration to review: %{company_name}'
    },
    'enterprise_email_admin_review_request_text' => {
      notes: 'Admin review request (text). Vars: %{company_name} %{applicant_email} %{company_contact_information} %{representative_contact_information} %{admin_url}.',
      body: <<~TEXT
        A new Lumen Enterprise registration was submitted and is waiting for review.

        Company name: %{company_name}
        Applicant email: %{applicant_email}

        Company contact information:
        %{company_contact_information}

        Representative contact information:
        %{representative_contact_information}

        Review, accept, or reject it here:
        %{admin_url}
      TEXT
    },
    'enterprise_email_admin_review_request_html' => {
      notes: 'Admin review request (HTML). Vars: %{company_name} %{applicant_email} %{company_contact_information} %{representative_contact_information} %{admin_url}.',
      body: <<~HTML
        <h1>New Lumen Enterprise registration to review</h1>

        <table>
          <tr><th align="left">Company name</th><td>%{company_name}</td></tr>
          <tr><th align="left">Applicant email</th><td>%{applicant_email}</td></tr>
        </table>

        <h2>Company contact information</h2>
        %{company_contact_information}

        <h2>Representative contact information</h2>
        %{representative_contact_information}

        <p><a href="%{admin_url}">Review, accept, or reject this registration</a></p>
      HTML
    },

    # --- Applicant: we received your request --------------------------------
    'enterprise_email_client_received_subject' => {
      notes: 'Applicant acknowledgement email subject.',
      body: 'We received your Lumen Enterprise registration'
    },
    'enterprise_email_client_received_text' => {
      notes: 'Applicant acknowledgement (text). Vars: %{company_name}.',
      body: <<~TEXT
        Hi,

        Thanks for registering %{company_name} for Lumen Enterprise. We have received your request and our team will review it.

        We will email you once we have made a decision. There is nothing you need to do right now.

        Thanks,
        The Lumen team
      TEXT
    },
    'enterprise_email_client_received_html' => {
      notes: 'Applicant acknowledgement (HTML). Vars: %{company_name}.',
      body: <<~HTML
        <h1>We received your registration</h1>

        <p>Thanks for registering <strong>%{company_name}</strong> for Lumen Enterprise. We have received your request and our team will review it.</p>

        <p>We will email you once we have made a decision. There is nothing you need to do right now.</p>

        <p>Thanks,<br>The Lumen team</p>
      HTML
    },

    # --- Applicant: rejected ------------------------------------------------
    'enterprise_email_client_rejected_subject' => {
      notes: 'Applicant rejection email subject.',
      body: 'About your Lumen Enterprise registration'
    },
    'enterprise_email_client_rejected_text' => {
      notes: 'Applicant rejection (text). Vars: %{company_name}.',
      body: <<~TEXT
        Hi,

        Thank you for your interest in Lumen Enterprise and for registering %{company_name}.

        After reviewing your request, we are sorry to say we are not able to accept it at this time.

        If you think this was a mistake or have questions, contact us at team@lumendatabase.org.

        Thanks,
        The Lumen team
      TEXT
    },
    'enterprise_email_client_rejected_html' => {
      notes: 'Applicant rejection (HTML). Vars: %{company_name}.',
      body: <<~HTML
        <h1>About your Lumen Enterprise registration</h1>

        <p>Thank you for your interest in Lumen Enterprise and for registering <strong>%{company_name}</strong>.</p>

        <p>After reviewing your request, we are sorry to say we are not able to accept it at this time.</p>

        <p>If you think this was a mistake or have questions, contact us at <a href="mailto:team@lumendatabase.org">team@lumendatabase.org</a>.</p>

        <p>Thanks,<br>The Lumen team</p>
      HTML
    },

    # --- Applicant: confirm email and set password --------------------------
    'enterprise_email_confirmation_subject' => {
      notes: 'Email-confirmation / set-password email subject (sent when an admin accepts).',
      body: 'Confirm your email and set your Lumen Enterprise password'
    },
    'enterprise_email_confirmation_text' => {
      notes: 'Email confirmation (text). Vars: %{company_name} %{confirmation_url}.',
      body: <<~TEXT
        Hi,

        Good news - your Lumen Enterprise registration for %{company_name} has been accepted.

        Confirm your email address and set your password to finish setting up your account:

        %{confirmation_url}

        After that you can sign in and choose a Pro plan from your settings.

        Thanks,
        The Lumen team
      TEXT
    },
    'enterprise_email_confirmation_html' => {
      notes: 'Email confirmation (HTML). Vars: %{company_name} %{confirmation_url}.',
      body: <<~HTML
        <h1>Confirm your email</h1>

        <p>Good news - your Lumen Enterprise registration for <strong>%{company_name}</strong> has been accepted.</p>

        <p>Confirm your email address and set your password to finish setting up your account:</p>

        <p><a href="%{confirmation_url}">Confirm your email and set your password</a></p>

        <p>After that you can sign in and choose a Pro plan from your settings.</p>

        <p>Thanks,<br>The Lumen team</p>
      HTML
    },

    # --- Admin: applicant confirmed their email -----------------------------
    'enterprise_email_admin_email_confirmed_subject' => {
      notes: 'Admin notification subject when an enterprise user confirms their email. Vars: %{company_name}.',
      body: 'Lumen Enterprise email confirmed: %{company_name}'
    },
    'enterprise_email_admin_email_confirmed_text' => {
      notes: 'Admin email-confirmed notification (text). Vars: %{company_name} %{user_email} %{admin_url}.',
      body: <<~TEXT
        The enterprise user for %{company_name} has confirmed their email.

        Company name: %{company_name}
        User email: %{user_email}

        View the account:
        %{admin_url}
      TEXT
    },
    'enterprise_email_admin_email_confirmed_html' => {
      notes: 'Admin email-confirmed notification (HTML). Vars: %{company_name} %{user_email} %{admin_url}.',
      body: <<~HTML
        <h1>Enterprise email confirmed</h1>

        <p>The enterprise user for <strong>%{company_name}</strong> has confirmed their email.</p>

        <table>
          <tr><th align="left">Company name</th><td>%{company_name}</td></tr>
          <tr><th align="left">User email</th><td>%{user_email}</td></tr>
        </table>

        <p><a href="%{admin_url}">View the account</a></p>
      HTML
    },

    # --- Admin: payment submitted -------------------------------------------
    'enterprise_email_admin_payment_subject' => {
      notes: 'Admin notification subject when an enterprise user submits a payment. Vars: %{company_name}.',
      body: 'Lumen Enterprise payment: %{company_name}'
    },
    'enterprise_email_admin_payment_text' => {
      notes: 'Admin payment notification (text). Vars: %{company_name} %{user_email} %{payment_method} %{plan} %{admin_url}.',
      body: <<~TEXT
        An enterprise user submitted a payment.

        Company name: %{company_name}
        User email: %{user_email}
        Payment method: %{payment_method}
        Plan: %{plan}

        View the account:
        %{admin_url}
      TEXT
    },
    'enterprise_email_admin_payment_html' => {
      notes: 'Admin payment notification (HTML). Vars: %{company_name} %{user_email} %{payment_method} %{plan} %{admin_url}.',
      body: <<~HTML
        <h1>Lumen Enterprise payment</h1>

        <p>An enterprise user submitted a payment.</p>

        <table>
          <tr><th align="left">Company name</th><td>%{company_name}</td></tr>
          <tr><th align="left">User email</th><td>%{user_email}</td></tr>
          <tr><th align="left">Payment method</th><td>%{payment_method}</td></tr>
          <tr><th align="left">Plan</th><td>%{plan}</td></tr>
        </table>

        <p><a href="%{admin_url}">View the account</a></p>
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
