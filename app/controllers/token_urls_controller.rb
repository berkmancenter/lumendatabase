require 'uri'
require 'net/http'
require 'hasher'

class TokenUrlsController < ApplicationController
  IP_BETWEEN_REQUESTS_WAITING_TIME = 2.hours

  def new
    @notice = Notice.find(params[:id])

    authorize! :request_access_token, @notice

    @token_url = TokenUrl.new
  end

  def create
    @new_token_params = token_url_params

    clean_up_email_address

    @original_email = @new_token_params[:email]
    @new_token_params[:email] = Hasher.hash512(@new_token_params[:email])
    @token_url = TokenUrl.new(@new_token_params)
    @token_url.ip = Hasher.hash512(request.remote_ip)
    @notice = Notice.where(id: @new_token_params[:notice_id]).first

    authorize!(:create_access_token, @notice) unless @notice.nil?

    valid_to_submit = validate

    if valid_to_submit[:status]
      @token_url[:expiration_date] = Time.now + LumenSetting.get_i('truncation_token_urls_active_period').seconds

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
      @original_email, @token_url, @notice
    ).deliver_later

    redirect_to(
      request_access_notice_path(@notice),
      notice: 'A new single-use link has been generated and sent to ' \
              'your email address.'
    )
  end

  def generate_permanent
    @notice = Notice.find(params[:id])

    authorize! :generate_permanent_notice_token_urls, @notice

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

  def validate
    if @notice.nil?
      return {
        status: false,
        why: 'Notice not found.'
      }
    end

    if ip_recently_requested?
      return {
        status: false,
        why: 'You have been submitting a request recently, try again later.'
      }
    end

    if ip_address_blocked?
      return {
        status: false,
        why: 'Your IP address has been blocked for abusing the service.'
      }
    end

    unless verify_recaptcha(action: 'new_token_url', minimum_score: 0.5)
      flash.delete(:recaptcha_error)

      return {
        status: false,
        why: 'Captcha verification failed, please try again.'
      }
    end

    if URI::MailTo::EMAIL_REGEXP.match(@original_email).nil?
      return {
        status: false,
        why: 'Use a valid email address.'
      }
    end

    if TokenUrl
       .where(email: @new_token_params[:email])
       .where('expiration_date > ?', Time.now)
       .any?
      return {
        status: false,
        why: 'This email address has been used already. Use a different ' \
             'email, wait until the previous url expires or contact our ' \
             'team at team@lumendatabase.org to get a researcher account.'
      }
    end

    if token_email_spam?
      return {
        status: false,
        why: 'This email address is not allowed. Try to use a different ' \
             'email address.'
      }
    end

    if token_ip_spam?
      return {
        status: false,
        why: 'This IP address is not allowed. Try to use a different ' \
             'IP address.'
      }
    end

    { status: true }
  end

  def disable_documents_notification_errors(token_url)
    return 'Token url was not found.' if token_url.nil?
    return 'Wrong token provided.' unless token_url.token == params[:token]
  end

  def token_email_spam?
    return true if BlockedTokenUrlDomain.where("'#{@original_email}' ~~* name").any?

    begin
      uri = URI("http://us.stopforumspam.org/api?email=#{@original_email}")
      res = Net::HTTP.get_response(uri)

      parsed_spam_response = Nokogiri::XML('<?xml version="1.0" encoding="utf-8"?>' + res.body)
      email_spam_frequency = parsed_spam_response.search('//frequency').text.to_i

      # If a frequency value is not 0 then it's spam
      !email_spam_frequency.zero?
    rescue
      # When the API is down just move along, not great but probably not going
      # to happen too often
      Rails.logger.warn 'Can\'t connect to the stopforumspam API.'
      false
    end
  end

  def token_ip_spam?
    begin
      uri = URI("http://us.stopforumspam.org/api?ip=#{request.remote_ip}")
      res = Net::HTTP.get_response(uri)

      parsed_spam_response = Nokogiri::XML('<?xml version="1.0" encoding="utf-8"?>' + res.body)
      ip_spam_frequency = parsed_spam_response.search('//frequency').text.to_i

      # If a frequency value is not 0 then it's spam
      !ip_spam_frequency.zero?
    rescue
      # When the API is down just move along, not great but probably not going
      # to happen too often
      Rails.logger.warn 'Can\'t connect to the stopforumspam API.'
      false
    end
  end

  def ip_address_blocked?
    BlockedTokenUrlIp.where(address: request.remote_ip).any?
  end

  def ip_recently_requested?
    TokenUrl
       .where(ip: Hasher.hash512(request.remote_ip))
       .where('created_at > ?', Time.now - IP_BETWEEN_REQUESTS_WAITING_TIME)
       .any?
  end

  def clean_up_email_address
    # Remove everything between + and @ and downcase it
    @new_token_params[:email].gsub!(/(\+.*?)(?=@)/, '')
    @new_token_params[:email].downcase!
    email_segments = @new_token_params[:email].split('@')
    # For Google "." means nothing, so let's remove it
    if ['gmail.com', 'googlemail.com'].any? { |domain| domain.include? email_segments[1] }
      @new_token_params[:email] = "#{email_segments[0].gsub('.', '')}@#{email_segments[1]}"
    end
  end
end
