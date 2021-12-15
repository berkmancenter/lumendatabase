class SubmitterWidgetNoticesController < NoticesController
  layout 'submitter_widget'
  before_action :before_actions

  def new
    # Iframe session won't be kept so we need to use GET params
    flash.now[params[:flash_message]['type']] = params[:flash_message]['message'] if params[:flash_message]

    @display_models = Notice.display_models - [DataProtection]

    if widget_settings[:visible_request_types]
      custom_types = widget_settings[:visible_request_types].split(',')
      @display_models = @display_models.select { |display_model| custom_types.include?(display_model.name) }
    end

    (render :submission_disabled and return) unless allowed_to_submit?
    (render 'notices/submitter_widget/select_type' and return) if params[:type].blank?

    build_new_notice

    render 'notices/submitter_widget/new'
  end

  def create
    unless authorized_to_create?
      Rails.logger.warn "Could not auth user with params: #{params}"
      redirect_to_new_form({
        type: 'alert',
        message: 'Something went wrong. Contact a website administrator.'
      }) and return
    end

    @notice = NoticeBuilder.new(
      get_notice_type(params), notice_params, submitter_widget_user
    ).build

    unless verify_recaptcha(action: 'submitter_widget_new_notice', minimum_score: 0.5)
      flash.delete(:recaptcha_error)
      flash.alert = 'Captcha verification failed, please try again.'
      strip_fixed_roles and render 'notices/submitter_widget/new' and return
    end

    if @notice.valid?
      @notice.save

      SubmitterWidgetMailer.send_submitted_notice_copy(@notice).deliver_later

      redirect_to_new_form({
        type: 'notice',
        message: 'Notice created! Thank you, it will be reviewed and published on the Lumen Database website.'
      }) and return
    else
      Rails.logger.warn "Could not create notice with params: #{params}"
      flash.alert = 'Notice creation failed. See errors below.'
    end

    strip_fixed_roles and render 'notices/submitter_widget/new' and return
  end

  private

  def build_entity_notice_roles(model_class)
    # We want the principal role to come first
    @notice.entity_notice_roles.build(name: 'principal').build_entity(
      kind: default_kind_based_on_role('principal')
    )

    model_class::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      next if %w[submitter recipient principal].include?(role)

      @notice.entity_notice_roles.build(name: role).build_entity(
        kind: default_kind_based_on_role(role)
      )
    end
  end

  def allowed_to_submit?
    widget_settings[:public_key] && submitter_widget_user
  end

  def authorized_to_create?
    allowed_to_submit?
  end

  def redirect_to_new_form(url_flash = nil)
    redirect_to new_submitter_widget_notice_path(widget_settings: widget_settings, flash_message: url_flash)
  end

  def submitter_widget_user
    User.find_by_widget_public_key(widget_settings[:public_key].to_s)
  end

  def default_kind_based_on_role(role)
    if role == 'issuing_court' ||
       (role == 'principal' && @notice.class == LawEnforcementRequest) ||
       (role == 'principal' && @notice.class == GovernmentRequest)
      'organization'
    else
      'individual'
    end
  end

  def before_actions
    # It will be an iframe and will run from different sites
    response.headers.delete 'X-Frame-Options'
    @widget_settings = widget_settings
  end

  def strip_fixed_roles
    @notice.entity_notice_roles = @notice.entity_notice_roles.reject { |entity_notice_role| %w[submitter recipient].include?(entity_notice_role.name) }
  end

  def widget_settings
    params.permit(widget_settings: [:public_key, :visible_request_types])[:widget_settings]
  end
end
