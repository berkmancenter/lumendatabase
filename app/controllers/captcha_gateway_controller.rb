class CaptchaGatewayController < ApplicationController
  def index
    redirect_to root_path and return if params[:destination].nil?

    if params['g-recaptcha-response']
      if verify_recaptcha
        session[:captcha_permission] = Time.now + ENV['CAPTCHA_GATEWAY_PERMISSION_TIME'].to_i.seconds
        redirect_to CGI.unescape(params[:destination]) and return
      else
        flash.delete(:recaptcha_error)
        flash.alert = 'Sorry, we don\'t think that you are a human, if you think this is an error please contact our team at team@lumendatabase.org.'
        redirect_to captcha_gateway_index_path(destination: params[:destination]) and return
      end
    end
  end
end
