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

  # In commit d7879d0 and prior, this was split into a two-part process with a
  # NoticeBuilder and a NoticeFinalizer. The idea here was that we'd create
  # Notices with stub works, and then background the time-consuming work + URL
  # creation step.
  # However, background processing adds a lot of complexity, and didn't seem
  # worth it in light of the fact that no one really cares if notice creation
  # is slow. Also, the format.html step when the notice was invalid was allowing
  # the stub notice to be created (which it should not!) but returning http 200
  # instead of 201 or 429, confusing clients.
  # Current code falls back to something more like the Rails standard. Not
  # exactly the same -- we still use NoticeBuilder to do some default-setting
  # and to create entity relationships -- but close enough that we can rely on
  # rails native error handling.
  # If you're reading this because you want to take another run at backgrounding
  # the expensive parts of notice creation, by all means check out the code
  # from that commit, but make sure to wrap ready_for_persistence? in a
  # transaction.
  def create
    return unauthorized_response unless authorized_to_create?

    @notice = NoticeBuilder.new(
      get_notice_type(params), notice_params, current_user
    ).build

    respond_to do |format|
      if @notice.valid?
        @notice.save
        @notice.mark_for_review
        flash.notice = "Notice created! It can be found at #{notice_url(@notice)}"
        format.json { head :created, location: @notice }
        format.html { redirect_to new_notice_url }
      else
        Rails.logger.warn "Could not create notice with params: #{params}"
        flash.alert = 'Notice creation failed. See errors below.'
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { notices: @notice.errors }, status: :unprocessable_entity }
      end
    end
  end

  def show
    return resource_not_found("Can't fing notice with id=#{params[:id]}") unless (@notice = Notice.find_by(id: params[:id]))

    update_stats

    @searchable_fields = Notice::SEARCHABLE_FIELDS
    @filterable_fields = Notice::FILTERABLE_FIELDS
    @ordering_options = Notice::ORDERING_OPTIONS
    @search_all_placeholder = 'Search all notices...'
    @search_index_path = notices_search_index_path

    respond_to do |format|
      format.html { show_render_html }
      format.json do
        render json: { json_root_for(@notice.class) => NoticeSerializerProxy.new(@notice) }
      end
    end
  end

  def feed
    notice_ids = Rails.cache.fetch(
      'recent_notices',
      expires_in: 1.hour
    ) do
      @notices = Notice.visible.recent
      @notices.pluck(:id)
    end

    @recent_notices ||= Notice.where(id: notice_ids)

    respond_to do |format|
      format.rss { render layout: false }
    end
  end

  def request_pdf
    @pdf = FileUpload.find(params[:id])
    @pdf.toggle!(:pdf_requested)
    render nothing: true
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

  private

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
      'search'
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

  def run_show_callbacks
    process_notice_viewer_request unless current_user.nil?
  end

  def process_notice_viewer_request
    # Only when the views limit is set for a user
    return unless current_user.full_notice_views_limit.present?
    # No need to update the counter when the limit is reached
    return if current_user.viewed_notices >= current_user.full_notice_views_limit

    current_user.increment!(:viewed_notices)
  end

  def show_render_html
    if @notice.rescinded?
      render :rescinded
    elsif @notice.hidden
      render 'error_pages/404_hidden',
             formats: [:html],
             status: :not_found,
             layout: false
    elsif @notice.spam || !@notice.published
      render 'error_pages/404_unavailable',
             formats: [:html],
             status: :not_found,
             layout: false
    else
      render :show
      run_show_callbacks
    end
  end

  def build_new_notice
    model_class = get_notice_type(params)
    @notice = model_class.new
    build_entity_notice_roles(model_class)
    @notice.file_uploads.build(kind: 'supporting')
    build_works(@notice)
  end

  def update_stats
    @notice.increment!(:views_overall)
    @notice.increment!(:views_by_notice_viewer) if !current_user.nil? && current_user.role?(Role.notice_viewer)

    return unless TokenUrl.valid?(params[:access_token], @notice)

    token_url = TokenUrl.find_by(token: params[:access_token])
    token_url.increment!(:views)
  end
end
