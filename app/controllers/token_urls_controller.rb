class TokenUrlsController < ApplicationController
  include Recaptcha::ClientHelper

  def new
    return unless (@notice = Notice.find(params[:id]))

    @token_url = TokenUrl.new
  end

  def create
    @token_url = TokenUrl.new(token_url_params)

    if valid_to_submit[:status]
      @token_url[:expiration_date] = Time.now + 24.hours

      if @token_url.save
        TokenUrlsMailer.send_new_url_confirmation(
          token_url_params[:email],
          @token_url,
          @notice
        ).deliver_later

        redirect_to(
          request_access_notice_path(@notice),
          notice: 'A new single-use link has been generated and sent you to ' \
                  'your email address'
        )
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

  private

  def token_url_params
    params.require(:token_url).permit(
      :email,
      :notice_id
    )
  end

  def valid_to_submit
    unless (@notice = Notice.find(token_url_params[:notice_id]))
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
        why: 'This email address has been used already, use a different ' \
             'address or contact our team to get a researcher account.'
      }
    end

    {
      status: true
    }
  end
end
