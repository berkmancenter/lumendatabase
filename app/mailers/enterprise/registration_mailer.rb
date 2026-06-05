class Enterprise::RegistrationMailer < ApplicationMailer
  default template_path: 'enterprise/registration_mailer'

  ADMIN_RECIPIENTS_SETTING = 'enterprise_registration_admin_emails'.freeze

  def admin_notification(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user

    recipients = admin_recipients
    return if recipients.empty?

    mail(
      to: recipients,
      subject: "New Lumen Enterprise registration: #{enterprise_account.name}"
    )
  end

  def client_confirmation(enterprise_account, user)
    @enterprise_account = enterprise_account
    @user = user

    mail(
      to: user.email,
      subject: 'Your Lumen Enterprise registration'
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
      subject: 'Your Lumen Enterprise access is ready'
    )
  end

  private

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
