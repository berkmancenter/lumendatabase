class Client::SettingsController < Client::BaseController
  def show
    @enterprise_account = enterprise_account
    @verified_domains = @enterprise_account.verified_domains.order(:domain)
  end

  def update
    if enterprise_account.update(settings_params)
      redirect_to client_settings_path, notice: 'Client settings updated.'
    else
      redirect_to(
        client_settings_path,
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
