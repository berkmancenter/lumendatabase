class Enterprise::RegistrationMailer < ApplicationMailer
  default template_path: 'enterprise/registration_mailer'

  ADMIN_RECIPIENTS_SETTING = 'enterprise_registration_admin_emails'.freeze

  # Sent to the configured admins when a new registration needs review. Includes
  # the submitted data and a link to the account's admin page so they can accept
  # or reject it. No user exists yet at this stage.
  def admin_review_request(enterprise_account)
    @enterprise_account = enterprise_account
    @admin_url = admin_account_url(enterprise_account)

    recipients = admin_recipients
    return if recipients.empty?

    mail(
      to: recipients,
      subject: format(
        Translation.t('enterprise_email_admin_review_request_subject'),
        company_name: enterprise_account.name
      )
    )
  end

  # Acknowledges the applicant that we received their registration and will
  # review it. Sent before any user exists, so it goes to the applicant email.
  def client_registration_received(enterprise_account)
    @enterprise_account = enterprise_account

    mail(
      to: enterprise_account.applicant_email,
      subject: Translation.t('enterprise_email_client_received_subject')
    )
  end

  # Tells the applicant their registration was not accepted.
  def client_rejected(enterprise_account)
    @enterprise_account = enterprise_account

    mail(
      to: enterprise_account.applicant_email,
      subject: Translation.t('enterprise_email_client_rejected_subject')
    )
  end

  # Sent when an admin accepts the registration: links to the page where the
  # user confirms their email and sets their password.
  def email_confirmation(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user
    @confirmation_url = enterprise_confirm_email_url(
      token: user.enterprise_email_confirmation_token,
      host: Chill::Application.config.site_host
    )

    mail(
      to: user.email,
      subject: Translation.t('enterprise_email_confirmation_subject')
    )
  end

  # Notifies admins that an enterprise user confirmed their email.
  def admin_email_confirmed(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user
    @admin_url = admin_account_url(enterprise_account)

    recipients = admin_recipients
    return if recipients.empty?

    mail(
      to: recipients,
      subject: format(
        Translation.t('enterprise_email_admin_email_confirmed_subject'),
        company_name: enterprise_account.name
      )
    )
  end

  # Notifies admins that an enterprise user submitted a payment.
  def admin_payment(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user
    @admin_url = admin_account_url(enterprise_account)

    recipients = admin_recipients
    return if recipients.empty?

    mail(
      to: recipients,
      subject: format(
        Translation.t('enterprise_email_admin_payment_subject'),
        company_name: enterprise_account.name
      )
    )
  end

  # Pro welcome, sent when an account becomes Pro through a credit-card payment.
  def client_confirmation(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user

    mail(
      to: user.email,
      subject: Translation.t('enterprise_email_client_confirmation_subject')
    )
  end

  # Renewal-invoice reminder, sent before an invoice-billed Pro account's paid
  # period ends. Informational only for now (no attachment).
  def renewal_invoice(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user
    @amount = renewal_amount

    mail(
      to: user.email,
      subject: Translation.t('enterprise_email_renewal_invoice_subject')
    )
  end

  # Sent when an admin accepts an invoice and activates the account. Tells the
  # client their Pro access is ready, through which date, and that they can log
  # in and use it now.
  def invoice_accepted(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user

    mail(
      to: user.email,
      subject: Translation.t('enterprise_email_invoice_accepted_subject')
    )
  end

  private

  # Absolute URL of the account's RailsAdmin show page, for admin emails.
  def admin_account_url(enterprise_account)
    rails_admin.show_url(
      model_name: 'enterprise_account',
      id: enterprise_account.id,
      host: Chill::Application.config.site_host
    )
  end

  # The renewal price, configured in dollars via LumenSetting, formatted as
  # currency. Falls back to neutral wording when no price is set.
  def renewal_amount
    price = LumenSetting.get('enterprise_pro_price_usd', cache: false)
    return 'the current Pro rate' if price.blank?

    ActiveSupport::NumberHelper.number_to_currency(price)
  end

  # Admin recipients are configured through LumenSetting and may be given as a
  # comma and/or newline separated list. Read live (cache: false) so updates take
  # effect without an application restart, and never expose the raw value.
  def admin_recipients
    LumenSetting
      .get(ADMIN_RECIPIENTS_SETTING, cache: false)
      .to_s
      .split(/[,\r\n]+/)
      .map(&:strip)
      .reject(&:blank?)
  end
end
