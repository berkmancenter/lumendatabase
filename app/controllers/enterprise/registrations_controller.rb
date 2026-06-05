# Public Lumen Enterprise sign-up. Lives in the enterprise namespace but, unlike
# its authenticated siblings, inherits ApplicationController directly so
# prospective customers can register before they have an account.
class Enterprise::RegistrationsController < ApplicationController
  def new
    @registration = EnterpriseRegistration.new
  end

  def create
    @registration = EnterpriseRegistration.new(registration_params)

    unless verify_recaptcha
      flash.delete(:recaptcha_error)
      flash.now.alert = 'Captcha verification failed, please try again.'
      return render :new
    end

    if @registration.save
      complete_registration
    else
      render :new
    end
  end

  private

  def complete_registration
    sign_in(@registration.user)

    if @registration.pro?
      redirect_to enterprise_my_notices_path,
                  notice: 'Welcome to Lumen Enterprise. Your Pro access is ready.'
    else
      redirect_to enterprise_status_path,
                  notice: 'Thanks - your Lumen Enterprise registration was received.'
    end
  end

  def registration_params
    params
      .require(:enterprise_registration)
      .permit(
        :email,
        :password,
        :password_confirmation,
        :company_name,
        :company_contact_information,
        :representative_contact_information,
        :payment_method
      )
  end
end
