class TokenUrlsController < ApplicationController
  include Recaptcha::ClientHelper

  def new
    @notice = Notice.find(params[:id])
    @token_url = TokenUrl.new
  end

  def create
    # Remove everything between + and @
    token_url_params[:email].gsub!(/(\+.*?)(?=@)/, '')
    @token_url = TokenUrl.new(token_url_params)
    @notice = Notice.where(id: token_url_params[:notice_id]).first

    if valid_to_submit[:status]
      @token_url[:expiration_date] = Time.now + 24.hours

      if @token_url.save
        run_post_create_actions
      else
        redirect_to(
          request_access_notice_path(@notice),
          alert: @token_url.errors.full_messages.join('<br>').html_safe
        )
      end
    else
      redirect_to(
        request_access_notice_path(@notice),
        alert: valid_to_submit[:why]
      )
    end
  end

  def run_post_create_actions
    TokenUrlsMailer.send_new_url_confirmation(
      token_url_params[:email], @token_url, @notice
    ).deliver_later

    redirect_to(
      request_access_notice_path(@notice),
      notice: 'A new single-use link has been generated and sent to ' \
              'your email address.'
    )
  end

  def generate_permanent
    @notice = Notice.find(params[:id])
    if cannot?(:generate_permanent_notice_token_urls, @notice)
      redirect_to(notice_path(@notice), alert: 'Not authorized')

      return
    end

    @token_url = TokenUrl.new(
      user: current_user,
      email: current_user.email,
      valid_forever: true,
      notice: @notice
    )

    if @token_url.save
      redirect_to(
        notice_path(@notice),
        notice: 'A permanent URL for this notice has been created. ' \
                'You can view it below.'
      )
    else
      redirect_to(
        notice_path(@notice),
        alert: @token_url.errors.full_messages.join('<br>').html_safe
      )
    end
  end

  def disable_documents_notification
    token_url = TokenUrl.find_by_id(params[:id])
    errors = disable_documents_notification_errors(token_url)

    return redirect_to(root_path, alert: errors) if errors.present?

    token_url.update_attribute(:documents_notification, false)
    redirect_to(
      root_path,
      notice: 'Documents notification has been disabled.'
    )
  end

  private

  def token_url_params
    params.require(:token_url).permit(
      :email,
      :notice_id,
      :documents_notification
    )
  end

  def valid_to_submit
    if @notice.nil?
      return {
        status: false,
        why: 'Notice not found.'
      }
    end

    unless verify_recaptcha(model: @token_url)
      return {
        status: false,
        why: 'Captcha verification failed, please try again.'
      }
    end

    if TokenUrl.where(email: token_url_params[:email]).any?
      return {
        status: false,
        why: 'This email address has been used already. Use a different ' \
             'email or contact our team at team@lumendatabase.org to get ' \
             'a researcher account.'
      }
    end

    {
      status: true
    }
  end

  def disable_documents_notification_errors(token_url)
    return 'Token url was not found.' if token_url.nil?
    return 'Wrong token provided.' unless token_url.token == params[:token]
  end
end
