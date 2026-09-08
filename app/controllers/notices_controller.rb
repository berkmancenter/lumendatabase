class NoticesController < ApplicationController
  layout :resolve_layout
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: :create

  # Notice validates the presence of works, but we delay adding works because
  # it is too time-consuming for the request/response cycle. Therefore we
  # need to add a placeholder so the Notice instance can save.
  PLACEHOLDER_WORKS = [Lumen::UNKNOWN_WORK].freeze

  def new
    (render :submission_disabled and return) if cannot?(:submit, Notice)
    (render :select_type and return) if params[:type].blank?

    build_new_notice
  end

  # HTML submissions retain the standard synchronous create flow. JSON
  # submissions are validated, stored as durable requests, and completed by a
  # background job using a notice ID reserved before the response is returned.
  def create
    return unauthorized_response unless authorized_to_create?

    notice_type = get_notice_type(params)
    submitted_params = notice_params
    Lumen::Submissions::Attachment.normalize!(submitted_params)

    respond_to do |format|
      format.json do
        create_json_notice(notice_type, submitted_params)
      end
      format.html do
        @notice = Lumen::NoticeBuilder.new(
          notice_type, submitted_params, current_user
        ).build
        if @notice.valid?
          @notice.save
          @notice.mark_for_review
          flash.notice = "Notice created! It can be found at #{notice_url(@notice)}"
          redirect_to new_notice_url
        else
          log_failed_notice
          flash.alert = 'Notice creation failed. See errors below.'
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    @searchable_fields = Notice::SEARCHABLE_FIELDS
    @filterable_fields = Notice::FILTERABLE_FIELDS
    @ordering_options = Notice::ORDERING_OPTIONS
    if current_user&.active_enterprise_account.present?
      @search_all_placeholder = 'Search your domain notices...'
      @search_index_path = enterprise_notices_search_index_path
    else
      @search_all_placeholder = 'Search all notices...'
      @search_index_path = notices_search_index_path
    end

    @notice = Notice.find_by(id: params[:id])
    unless @notice
      @notice_submission_request = NoticeSubmissionRequest
        .select(:id, :reserved_notice_id, :status)
        .find_by(reserved_notice_id: params[:id])
      return render_processing_notice if @notice_submission_request

      return resource_not_found("Can't fing notice with id=#{params[:id]}")
    end

    respond_to do |format|
      format.html do
        update_html_stats
        show_render_html
      end
      format.json do
        if json_show_allowed?
          render json: { json_root_for(@notice.class) => Lumen::NoticeSerializerProxy.new(@notice) }
        else
          resource_not_found
        end
      end
    end
  end

  def feed
    notice_ids = Rails.cache.fetch(
      'recent_notices',
      expires_in: 1.hour
    ) do
      Notice.visible.recent.pluck(:id)
    end

    @recent_notices = Notice.visible_for_display(notice_ids)

    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  def request_pdf
    @pdf = FileUpload.find(params[:id])
    @pdf.toggle!(:pdf_requested)
    head :ok, content_type: 'text/html'
  end

  # This can't be in 'private' because it is invoke by JavaScript to add
  # additional URL inputs to the page; if it's private, that JS call fails.
  def url_input
    notice = get_notice_type(params).new
    @options = OpenStruct.new(
      notice: notice,
      url_type: params[:url_type].to_sym,
      main_index: params[:index].to_i,
      child_index: (Time.now.to_f * 10_000).to_i
    )
    build_works(notice)
  end

  def start_receive_document_notifications
    return resource_not_found("Can't fing notice with id=#{params[:id]}") unless (@notice = Notice.find_by(id: params[:id]))
    return unless current_user

    existing = DocumentNotificationEmail
      .where(
        notice_id: params[:id],
        email_address: current_user.email,
      )
      .first

    if (existing.present?)
      existing.update(status: 1)
    else
      DocumentNotificationEmail
        .create(
          notice_id: params[:id],
          email_address: current_user.email,
        )
    end

    redirect_to(
      notice_path(@notice),
      notice: 'You have started watching this notice.'
    )
  end

  def stop_receive_document_notifications
    return resource_not_found("Can't fing notice with id=#{params[:id]}") unless (@notice = Notice.find_by(id: params[:id]))
    return unless current_user

    DocumentNotificationEmail
      .where(
        notice_id: params[:id],
        email_address: current_user.email,
      )
      .update(status: 0)

    redirect_to(
      notice_path(@notice),
      notice: 'You have stopped watching this notice.'
    )
  end

  def disable_document_notification
    document_notification_email = DocumentNotificationEmail.find_by_token(params[:token])
    errors = disable_documents_notification_errors(document_notification_email)

    return redirect_to(root_path, alert: errors) if errors.present?

    document_notification_email.update(status: 0)

    redirect_to(
      root_path,
      notice: "Document notifications for notice #{document_notification_email.notice.id} have been disabled."
    )
  end

  private

  def create_json_notice(notice_type, submitted_params)
    @notice = Lumen::NoticeBuilder.new(
      notice_type,
      submitted_params.except('file_uploads_attributes'),
      current_user
    ).build
    notice_valid = valid_json_notice?
    attachments_valid = Lumen::Submissions::AttachmentValidator.new(
      submitted_params
    ).validate(@notice.errors)

    unless notice_valid && attachments_valid
      log_failed_notice
      render json: { notices: @notice.errors }, status: :unprocessable_entity
      return
    end

    submission_request = Lumen::Submissions::Intake.new(
      notice_type: notice_type,
      payload: submitted_params,
      submitted_by: current_user,
      request_id: request.request_id
    ).call
    enqueue_notice_submission(submission_request)

    head :created,
         location: notice_url(submission_request.reserved_notice_id)
  end

  def valid_json_notice?
    valid = false

    Notice.transaction(requires_new: true) do
      valid = @notice.valid?
      raise ActiveRecord::Rollback
    end

    valid
  end

  def enqueue_notice_submission(submission_request)
    return if submission_request.completed?

    Lumen::Submissions::Enqueuer.new(submission_request.id).call
  rescue StandardError => error
    Rails.logger.error(
      "Notice submission #{submission_request.id} was stored but could not " \
      "be enqueued: #{error.class}: #{error.message}"
    )
  end

  def log_failed_notice
    Lumen::Logger.log_metrics(
      'FAILED_CREATE_NEW_NOTICE',
      notice_errors: @notice.errors
    )
  end

  def render_processing_notice
    respond_to do |format|
      format.html { render :processing, status: :accepted }
      format.json do
        render json: {
          notice: {
            id: @notice_submission_request.reserved_notice_id,
            status: 'processing'
          }
        }, status: :accepted
      end
    end
  end

  def unauthorized_response
    self.status = :unauthorized
    self.response_body = { documentation_link: Rails.configuration.x.api_documentation_link }.to_json
    return
  end

  def json_root_for(klass)
    klass.to_s.tableize.singularize
  end

  def notice_params
    raw_params = params.require(:notice).except(:type).permit(
      :title,
      :subject,
      :body,
      :date_sent,
      :date_received,
      :source,
      :tag_list,
      :jurisdiction_list,
      :regulation_list,
      :language,
      :action_taken,
      :request_type,
      :mark_registration_number,
      :url_count,
      :webform,
      :counternotice_for_id,
      :counternotice_for_sid,
      :case_id_number,
      topic_ids: [],
      file_uploads_attributes: %i[kind file file_name],
      entity_notice_roles_attributes: [
        :entity_id,
        :name,
        entity_attributes: entity_params
      ],
      works_attributes: work_params
    )
    raw_params.to_h
  end

  def entity_params
    %i[name kind address_line_1 address_line_2 city state zip country_code
       phone email url full_notice_only_researchers]
  end

  def work_params
    [
      :description,
      :kind,
      infringing_urls_attributes: [:url],
      copyrighted_urls_attributes: [:url]
    ]
  end

  def resolve_layout
    case action_name
    when 'show'
      current_user&.active_enterprise_account.present? ? 'enterprise' : 'search'
    when 'url_input'
      false
    else
      'application'
    end
  end

  # In theory the calls to fetch and delete cause memory leaks per
  # https://tenderlovemaking.com/2014/06/02/yagni-methods-are-killing-me.html ,
  # but with benchmarking on localhost I'm unable to find a meaningful memory
  # usage difference between this version and a version that avoids these calls.
  # --ay, 11 December 2018
  def get_notice_type(params)
    type_string = params[:type] || params[:notice][:type] || 'DMCA'
    type_string = 'DMCA' if type_string == 'Dmca'

    notice_type = type_string.classify.constantize

    if notice_type < Notice
      notice_type
    else
      DMCA
    end
  rescue NameError
    DMCA
  ensure
    params.delete(:type)
  end

  def default_kind_based_on_role(role)
    if role == 'issuing_court'
      'organization'
    else
      'individual'
    end
  end

  def build_entity_notice_roles(model_class)
    model_class::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      @notice.entity_notice_roles.build(name: role).build_entity(
        kind: default_kind_based_on_role(role)
      )
    end
  end

  def build_works(notice)
    notice.works = [
      Work.new(
        copyrighted_urls: [CopyrightedUrl.new],
        infringing_urls: [InfringingUrl.new]
      )
    ]
  end

  def authorized_to_create?
    if cannot?(:submit, Notice)
      false
    else
      true
    end
  end

  def json_show_allowed?
    current_user&.role?(:super_admin) ||
      Notice.visible_qualifiers.except(:rescinded).all? do |field, expected_value|
        @notice.public_send(field) == expected_value
      end
  end

  def process_notice_viewer_request
    return unless current_user.role?(:notice_viewer)
    # Only when the views limit is set for a user
    return unless current_user.full_notice_views_limit.present?
    # No need to update the counter when the limit is reached
    return if current_user.viewed_notices >= current_user.full_notice_views_limit

    current_user.increment!(:viewed_notices)
  end

  def show_render_html
    if @notice.hidden
      render 'error_pages/404_hidden',
             formats: [:html],
             status: :not_found,
             layout: false
    elsif @notice.rescinded?
      render :rescinded
    elsif @notice.spam || !@notice.published
      render 'error_pages/404_unavailable',
             formats: [:html],
             status: :not_found,
             layout: false
    else
      render :show
    end
  end

  def build_new_notice
    model_class = get_notice_type(params)
    @notice = model_class.new
    build_entity_notice_roles(model_class)
    @notice.file_uploads.build(kind: 'supporting')
    build_works(@notice)
  end

  def update_html_stats
    process_notice_viewer_request unless current_user.nil?

    @notice.increment!(:views_overall)
    @notice.increment!(:views_by_notice_viewer) if !current_user.nil? && current_user.role?(:notice_viewer)

    return unless TokenUrl.valid?(params[:access_token], @notice)

    token_url = TokenUrl.find_by(token: params[:access_token])
    token_url.increment!(:views)
  end

  def disable_documents_notification_errors(document_notification_email)
    return 'Documents notification was not found.' if document_notification_email.nil?
  end
end
