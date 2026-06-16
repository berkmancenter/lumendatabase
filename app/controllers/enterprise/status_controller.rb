# Backward-compatible endpoint for old Enterprise account-status links. The
# status UI now lives inside settings.
class Enterprise::StatusController < ApplicationController
  before_action :authenticate_user!

  def show
    return redirect_to(enterprise_my_notices_path) if current_user.active_enterprise_account
    return redirect_to(enterprise_settings_path) if current_user.confirmed_enterprise_user?

    redirect_to root_path, alert: 'Enterprise access is not active for this account.'
  end
end
