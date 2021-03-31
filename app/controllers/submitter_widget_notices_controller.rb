class SubmitterWidgetNoticesController < NoticesController
  layout 'submitter_widget'

  def new
    response.headers.delete 'X-Frame-Options'

    (render :submission_disabled and return) unless allowed_to_submit?
    (render :select_type and return) if params[:type].blank?

    build_new_notice
  end

  private

  def allowed_to_submit?
    widget_public_key &&
      User.find_by_widget_public_key(widget_public_key.to_s)
  end

  def widget_public_key
    key = 'widget_public_key'

    params[key] || request.env["HTTP_X_#{key.upcase}"]
  end
end
