# Enterprise account and report-delivery settings. Account is reachable once a
# user has confirmed their email; report delivery updates require Pro access.
class Enterprise::SettingsController < Enterprise::ConfirmedBaseController
  def show
    @enterprise_account = enterprise_account
    @pending_payment = @enterprise_account.pending_payment
  end

  def update
    unless enterprise_account.pro?
      return redirect_to enterprise_account_path,
                         alert: 'Choose a Pro plan before changing these settings.'
    end

    if enterprise_account.update(settings_params)
      redirect_to enterprise_reports_path, notice: 'Report settings updated.'
    else
      redirect_to(
        enterprise_reports_path,
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
