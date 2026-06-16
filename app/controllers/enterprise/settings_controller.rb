# Enterprise settings. Reachable once a user has confirmed their email, even
# before they have paid: not-yet-Pro accounts see the "Get Pro" payment options,
# Pro accounts see the full reports/domains settings.
class Enterprise::SettingsController < Enterprise::ConfirmedBaseController
  def show
    @enterprise_account = enterprise_account
    @pending_payment = @enterprise_account.pending_payment
    @enterprise_domains = @enterprise_account.enterprise_domains.order(:domain)
  end

  def update
    unless enterprise_account.pro?
      return redirect_to enterprise_settings_path,
                         alert: 'Choose a Pro plan before changing these settings.'
    end

    if enterprise_account.update(settings_params)
      redirect_to enterprise_settings_path, notice: 'Enterprise settings updated.'
    else
      redirect_to(
        enterprise_settings_path,
        alert: enterprise_account.errors.full_messages.join('<br>').html_safe
      )
    end
  end

  private

  def settings_params
    params
      .require(:enterprise_account)
      .permit(:report_frequency, :report_recipient_email)
  end
end
