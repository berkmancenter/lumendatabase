class Enterprise::ReportsController < ApplicationController
  before_action :authenticate_user!, only: :create
  before_action :require_active_enterprise_account!, only: :create

  def create
    enterprise_report = enterprise_account.enterprise_reports.build(
      report_attributes.merge(
        requested_by: current_user,
        requested_by_email: current_user.email
      )
    )

    if enterprise_report.save
      EnterpriseReportJob.perform_later(enterprise_report.id)
      redirect_to enterprise_settings_path,
                  notice: 'Report requested. We will email you when it is ready to download.'
    else
      redirect_to enterprise_settings_path,
                  alert: enterprise_report.errors.full_messages.join('<br>').html_safe
    end
  rescue ActionController::ParameterMissing, ArgumentError => e
    redirect_to enterprise_settings_path, alert: e.message
  end

  def show
    enterprise_report = EnterpriseReport.find_by!(
      download_token: params[:token]
    )

    return head :not_found unless enterprise_report.downloadable?

    send_data(
      enterprise_report.file.download,
      filename: enterprise_report.download_filename,
      type: 'application/json',
      disposition: 'attachment'
    )
  end

  private

  def require_active_enterprise_account!
    return if current_user&.active_enterprise_account

    redirect_to root_path, alert: 'Enterprise access is not active for this account.'
  end

  def enterprise_account
    @enterprise_account ||= current_user.active_enterprise_account
  end

  def report_attributes
    permitted_params = params
                       .require(:enterprise_report)
                       .permit(:starts_on, :ends_on)
    starts_on = parse_date(permitted_params[:starts_on], 'Start date')
    ends_on = parse_date(permitted_params[:ends_on], 'End date')

    if starts_on > ends_on
      raise ArgumentError, 'End date must be on or after start date.'
    end

    {
      starts_at: starts_on.in_time_zone.beginning_of_day,
      ends_at: ends_on.in_time_zone.end_of_day
    }
  end

  def parse_date(value, label)
    raise ArgumentError, "#{label} is required." if value.blank?

    Date.iso8601(value)
  rescue Date::Error
    raise ArgumentError, "#{label} must be a valid date."
  end
end
