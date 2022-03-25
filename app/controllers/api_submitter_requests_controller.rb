class ApiSubmitterRequestsController < ApplicationController
  def new
    @api_submitter_request = ApiSubmitterRequest.new
  end

  def create
    @api_submitter_request = ApiSubmitterRequest.new(api_submitter_request_params)

    if verify_recaptcha
      if @api_submitter_request.save
        run_post_create_actions
      else
        flash.alert = @api_submitter_request.errors.full_messages.join('<br>').html_safe
        render 'new'
      end
    else
      flash.delete(:recaptcha_error)
      flash.alert = 'Captcha verification failed, please try again.'
      render 'new'
    end
  end

  private

  def run_post_create_actions
    redirect_to(
      new_api_submitter_request_path,
      notice: 'We have received your application, you will receive an email from us when we verify your request.'
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
end
