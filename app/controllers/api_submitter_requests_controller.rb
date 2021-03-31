class ApiSubmitterRequestsController < ApplicationController
  include Recaptcha::ClientHelper

  def new
    @api_submitter_request = ApiSubmitterRequest.new
  end

  def create
    # Remove everything between + and @
    api_submitter_request_params[:email].gsub!(/(\+.*?)(?=@)/, '')
    @api_submitter_request = ApiSubmitterRequest.new(api_submitter_request_params)

    valid_to_submit = validate

    if valid_to_submit[:status]
      if @api_submitter_request.save
        run_post_create_actions
      else
        redirect_to(
          api_submitter_requests_path(@api_submitter_request),
          alert: @api_submitter_request.errors.full_messages.join('<br>').html_safe
        )
      end
    else
      redirect_to(
        api_submitter_requests_path(@api_submitter_request),
        alert: valid_to_submit[:why]
      )
    end
  end

  private

  def run_post_create_actions
    redirect_to(
      new_api_submitter_request_path,
      notice: 'We have received your application, you should receive an email from us within 48 hours.'
    )
  end

  def api_submitter_request_params
    params.require(:api_submitter_request).permit(
      :email,
      :submissions_forward_email,
      :description,
      :entity_name,
      :entity_kind,
      :entity_address_line_1,
      :entity_address_line_2,
      :entity_state,
      :entity_country_code,
      :entity_phone,
      :entity_url,
      :entity_email,
      :entity_city,
      :entity_zip
    )
  end

  def validate
    unless verify_recaptcha(model: @api_submitter_request)
      return {
        status: false,
        why: 'Captcha verification failed, please try again.'
      }
    end

    {
      status: true
    }
  end
end
