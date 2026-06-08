# Handles the confirm-email + set-password link sent when an admin accepts a
# registration. The single-use token identifies the user; submitting the form
# sets their password, confirms the email, signs them in, and notifies admins.
class Enterprise::EmailConfirmationsController < ApplicationController
  before_action :load_user_by_token

  def show; end

  def update
    if @user.update(password_params)
      @user.confirm_enterprise_email!

      Enterprise::RegistrationMailer
        .admin_email_confirmed(@user.enterprise_account, @user)
        .deliver_later

      sign_in(@user)

      redirect_to enterprise_settings_path,
                  notice: 'Your email is confirmed. Choose a Pro plan to get started.'
    else
      render :show
    end
  end

  private

  def load_user_by_token
    @user = User.find_by(enterprise_email_confirmation_token: params[:token].to_s.presence)
    return if @user

    redirect_to new_user_session_path,
                alert: 'That confirmation link is invalid or has already been used.'
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
