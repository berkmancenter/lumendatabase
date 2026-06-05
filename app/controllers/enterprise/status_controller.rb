# Landing page for signed-in enterprise users whose account is not yet on the
# Pro plan. It explains how to activate based on the chosen payment method.
# Unlike the Enterprise::BaseController controllers it only requires the user to
# be signed in (not Pro) - that's the whole point of the page.
class Enterprise::StatusController < ApplicationController
  before_action :authenticate_user!

  def show
    return redirect_to(enterprise_my_notices_path) if current_user.active_enterprise_account

    @enterprise_account = current_user.enterprise_account
  end
end
