class SubmitterWidgetNoticesController < NoticesController
  layout 'submitter_widget'

  def new
    response.headers.delete 'X-Frame-Options'

    @display_models = Notice.display_models - [Counternotice, DataProtection]
    @widget_public_key = params[:widget_public_key]

    (render :submission_disabled and return) unless allowed_to_submit?
    (render 'notices/submitter_widget/select_type' and return) if params[:type].blank?

    build_new_notice

    render 'notices/submitter_widget/new'
  end

  def create
    response.headers.delete 'X-Frame-Options'

    @widget_public_key = params[:widget_public_key]

    unless authorized_to_create?
      Rails.logger.warn "Could not auth user with params: #{params}"
      flash.alert = 'Something went wrong. Contact a website administrator.'
      redirect_to_new_form and return
    end

    @notice = NoticeBuilder.new(
      get_notice_type(params), notice_params, current_user
    ).build

    if @notice.valid?
      @notice.save
      @notice.mark_for_review
      flash.notice = 'Notice created! Thank you, it will be reviewed and published on the Lumen database website.'
    else
      Rails.logger.warn "Could not create notice with params: #{params}"
      flash.alert = 'Notice creation failed. See errors below.'
    end

    redirect_to_new_form
  end

  private

  def build_entity_notice_roles(model_class)
    model_class::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      next if %w[sender recipient].include?(role)

      @notice.entity_notice_roles.build(name: role).build_entity(
        kind: default_kind_based_on_role(role)
      )
    end
  end

  def allowed_to_submit?
    widget_public_key &&
      User.find_by_widget_public_key(widget_public_key.to_s)
  end

  def authorized_to_create?
    allowed_to_submit?
  end

  def widget_public_key
    key = 'widget_public_key'

    params[key] || request.env["HTTP_X_#{key.upcase}"]
  end

  def redirect_to_new_form
    redirect_to new_submitter_widget_notice_path(type: params[:notice][:type], widget_public_key: @widget_public_key)
  end
end
