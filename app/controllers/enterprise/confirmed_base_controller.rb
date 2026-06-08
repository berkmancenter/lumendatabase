# Base for enterprise pages an approved, email-confirmed user can reach even
# before they have paid for Pro (settings and payment). Pro-only pages use
# Enterprise::BaseController instead, which additionally requires an active
# (Pro) account.
class Enterprise::ConfirmedBaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_confirmed_enterprise_user!

  private

  def require_confirmed_enterprise_user!
    return if current_user&.confirmed_enterprise_user?

    redirect_to root_path, alert: 'Enterprise access is not active for this account.'
  end

  def enterprise_account
    @enterprise_account ||= current_user.enterprise_account
  end
end
