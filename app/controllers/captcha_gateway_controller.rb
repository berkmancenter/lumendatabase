class CaptchaGatewayController < ApplicationController
  def index
    redirect_to root_path and return if params[:destination].nil?

    if params.dig('g-recaptcha-response-data', 'gateway')
      success_captcha = verify_recaptcha(action: 'gateway', minimum_score: 0.5)

      captcha_gateway_logger = Logger.new("#{Rails.root}/log/captcha_gateway_logger.log")
      captcha_gateway_logger.info(recaptcha_reply.inspect)

      if success_captcha
        session[:captcha_permission] = Time.now + ENV['CAPTCHA_GATEWAY_PERMISSION_TIME'].to_i.seconds
        redirect_to CGI.unescape(params[:destination]) and return
      else
        flash.delete(:recaptcha_error)
        flash.alert = 'Sorry, we don\'t this that you are a human, if you think this is an error please contact our team at team@lumendatabase.org.'
        redirect_to root_path and return
      end
    end
  end
end
