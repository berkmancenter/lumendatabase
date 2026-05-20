class Client::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_enterprise_account!

  private

  def require_enterprise_account!
    return if current_user&.active_enterprise_account

    redirect_to root_path, alert: 'Client access is not active for this account.'
  end

  def enterprise_account
    @enterprise_account ||= current_user.active_enterprise_account
  end
end
