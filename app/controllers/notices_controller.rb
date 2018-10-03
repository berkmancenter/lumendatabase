class NoticesController < ApplicationController
  layout :resolve_layout

  skip_before_action :verify_authenticity_token, only: :create

  def new
    (render :submission_disabled and return) if cannot?(:submit, Notice)

    (render :select_type and return) if params[:type].blank?

    model_class = get_notice_type(params)
    @notice = model_class.new
    build_entity_notice_roles(model_class)
    @notice.file_uploads.build(kind: 'supporting')
    build_works(@notice)
  end

  def create
    respond_to do |format|
      format.json do
        return unless authorized_to_create?
        create_respond_json
      end

      format.html { create_respond_html }
    end
  end

  def show
    return unless (@notice = Notice.find(params[:id]))
    respond_to do |format|
      format.html do
        if @notice.rescinded?
          render :rescinded
        elsif @notice.hidden || @notice.spam || !@notice.published
          render file: 'public/404_unavailable',
                 formats: [:html],
                 status: :not_found,
                 layout: false
        else
          render :show
        end
      end

      format.json do
        serializer = researcher? ? NoticeSerializerProxy : LimitedNoticeSerializerProxy
        render json: @notice,
               serializer: serializer,
               root: json_root_for(@notice.class)
      end
    end
  end

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

  def feed
    @recent_notices = Rails.cache.fetch(
      'recent_notices',
      expires_in: 1.hour
    ) { Notice.visible.recent }
    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  def request_pdf
    @pdf = FileUpload.find(params[:id])
    @pdf.toggle!(:pdf_requested)
    render nothing: true
  end

  private

  # These parameters will be added to the Notice instance during the delayed
  # job outside of the request/response loop. Skylight reveals that adding
  # infringing_urls is slow, particularly if the number is large, and involves
  # repeated SQL queries. Tracking down those queries is much harder than
  # delegating the job to a place where it won't annoy users.
  DELAYED_PARAMS = %i[works_attributes].freeze

  def json_root_for(klass)
    klass.to_s.tableize.singularize
  end

  def notice_params
    params.require(:notice).except(:type).permit(
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
      topic_ids: [],
      file_uploads_attributes: %i[kind file file_name],
      entity_notice_roles_attributes: [
        :entity_id,
        :name,
        entity_attributes: entity_params
      ],
      works_attributes: work_params
    )
  end

  def entity_params
    %i[name kind address_line_1 address_line_2 city state zip country_code
       phone email url]
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
      'search'
    when 'url_input'
      false
    else
      'application'
    end
  end

  def get_notice_type(params)
    type_string = params.fetch(:type, 'DMCA')
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

  def researcher?
    return false unless request.headers['HTTP_X_AUTHENTICATION_TOKEN']
    User.find_by_authentication_token(
      request.headers['HTTP_X_AUTHENTICATION_TOKEN']
    ).has_role?(Role.researcher)
  end

  def build_entity_notice_roles(model_class)
    model_class::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      @notice.entity_notice_roles.build(name: role).build_entity(
        kind: default_kind_based_on_role(role)
      )
    end
  end

  def build_works(notice)
    notice.works.build do |w|
      w.copyrighted_urls.build
      w.infringing_urls.build
    end
  end

  def authorized_to_create?
    if cannot?(:submit, Notice)
      head :unauthorized
      false
    else
      true
    end
  end

  def preliminary_submission
    NoticeSubmissionInitializer.new(
      get_notice_type(params[:notice]),
      initial_params
    )
  end

  # initial_params are used to create the notice instance. final_params are
  # used to update it in the delayed job.
  def initial_params
    notice_params.except(*DELAYED_PARAMS)
  end

  def final_params
    notice_params.slice(*DELAYED_PARAMS)
  end

  def finalize(notice)
    NoticeSubmissionFinalizer.new(notice, final_params).finalize
  end

  def create_respond_json
    submission = preliminary_submission

    if submission.submit(current_user)
      finalize(submission.notice)
      head :created, location: submission.notice
    else
      render json: submission.errors, status: :unprocessable_entity
    end
  end

  def create_respond_html
    submission = preliminary_submission

    if submission.submit(current_user)
      finalize(submission.notice)
      redirect_to :root, notice: 'Notice created!'
    else
      @notice = submission.notice
      render :new
    end
  end

  def json_errors(notice)
    if notice.present?
      notice.errors
    else
      msg = 'You are not authorized to do that, or you are missing required ' \
            'parameters'.freeze
      { errors: msg }
    end
  end
end
