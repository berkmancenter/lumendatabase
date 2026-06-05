class AddEnterpriseRenewalInvoiceTranslations < ActiveRecord::Migration[7.2]
  # Editable copy for the renewal-invoice reminder emailed to invoice-billed Pro
  # accounts before their paid period ends. Interpolation uses Ruby `format` with
  # %{named} placeholders.
  TRANSLATIONS = {
    'enterprise_email_renewal_invoice_subject' => {
      notes: 'Subject of the renewal-invoice reminder email.',
      body: 'Your Lumen Enterprise renewal invoice'
    },
    'enterprise_email_renewal_invoice_text' => {
      notes: 'Renewal-invoice reminder email (text). Vars: %{company_name} %{ends_on} %{amount} %{settings_url}.',
      body: <<~TEXT
        Hi,

        Your Lumen Enterprise Pro access for %{company_name} is set to end on %{ends_on}.

        Here is your invoice to renew Lumen Enterprise Pro for another month: %{amount}.

        Please arrange payment before %{ends_on} so your Pro access continues without interruption. Once we have processed your payment we will extend your access and let you know.

        You can review your plan here: %{settings_url}

        Thanks,
        The Lumen team
      TEXT
    },
    'enterprise_email_renewal_invoice_html' => {
      notes: 'Renewal-invoice reminder email (HTML). Vars: %{company_name} %{ends_on} %{amount} %{settings_url}.',
      body: <<~HTML
        <h1>Your Lumen Enterprise renewal invoice</h1>

        <p>Your Lumen Enterprise Pro access for <strong>%{company_name}</strong> is set to end on <strong>%{ends_on}</strong>.</p>

        <p>Here is your invoice to renew Lumen Enterprise Pro for another month: <strong>%{amount}</strong>.</p>

        <p>Please arrange payment before %{ends_on} so your Pro access continues without interruption. Once we have processed your payment we will extend your access and let you know.</p>

        <p>You can <a href="%{settings_url}">review your plan</a> any time.</p>

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
