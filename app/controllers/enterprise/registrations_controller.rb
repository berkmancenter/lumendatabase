# Public Lumen Enterprise sign-up. Lives in the enterprise namespace but, unlike
# its authenticated siblings, inherits ApplicationController directly so
# prospective customers can register before they have an account. A registration
# only creates a pre_registration account (no user, no payment); an admin reviews
# it and the user is created on accept.
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
      redirect_to enterprise_registration_received_path
    else
      render :new
    end
  end

  # "Thanks, we'll review your request" page shown after a successful sign-up.
  def received; end

  private

  def registration_params
    params
      .require(:enterprise_registration)
      .permit(
        :email,
        :company_name,
        :company_contact_information,
        :representative_contact_information,
        :interested_domains
      )
  end
end
