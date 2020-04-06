class NoticesController < ApplicationController
  layout :resolve_layout
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: :create

  # Notice validates the presence of works, but we delay adding works because
  # it is too time-consuming for the request/response cycle. Therefore we
  # need to add a placeholder so the Notice instance can save.
  PLACEHOLDER_WORKS = [Work.unknown].freeze

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
    return unauthorized_response unless authorized_to_create?

    @notice = NoticeBuilder.new(
      get_notice_type(params), notice_params, current_user
    ).build

    respond_to do |format|
      if @notice.valid? && ready_for_persistence?
        format.json { head :created, location: @notice }
        format.html { redirect_to :root, notice: 'Notice created!' }
      else
        format.html  { render :new }
        format.json  { render json: @notice.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    return unless (@notice = Notice.find(params[:id]))

    respond_to do |format|
      show_html format
      show_json format
    end
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
    notice.works.build do |w|
      w.copyrighted_urls.build
      w.infringing_urls.build
    end
  end

  def authorized_to_create?
    if cannot?(:submit, Notice)
      false
    else
      true
    end
  end

  def ready_for_persistence?
    original_works = @notice.works.to_ary
    @notice.works = PLACEHOLDER_WORKS

    if @notice.save
      @notice.mark_for_review
      # The following two lines need to be backgrounded eventually
      @notice.works.delete(PLACEHOLDER_WORKS)
      fix_concatenated_urls(original_works)
      @notice.works << original_works
      true
    else
      @notice.works.delete(PLACEHOLDER_WORKS)
      # Important: this does _not_ create the works if they have not yet been
      # saved, so we're not putting that slowdown into the request/response loop
      # here. It just restores the unsaved objects to the collection.
      @notice.works << original_works
      false
    end
  end

  def fix_concatenated_urls(works)
    return unless works.present?
    works.each do |work|
      work.copyrighted_urls << fixed_urls(work, :copyrighted_urls)
      work.infringing_urls << fixed_urls(work, :infringing_urls)
    end
  end

  def fixed_urls(work, url_type)
    new_urls = []
    work.send(url_type).each do |url_obj|
      next unless url_obj[:url].scan('/http').present?

      split_urls = conservative_split(url_obj[:url])
      # Overwrite the current URL with one of the split-apart URLs. Then
      # add the rest of the split-apart URLs to a list for safekeeping.
      url_obj[:url] = split_urls.pop()
      split_urls_as_hashes = split_urls.map { |url| { url: url } }
      new_urls << work.send(url_type).build(split_urls_as_hashes)
    end
    new_urls
  end

  # We can't just split on 'http', because doing so will result in strings
  # which no longer contain it. We need to look at the pairs of 'http' and
  # $the_rest_of_the_URL which split produces and then mash them back together.
  def conservative_split(s)
    b = []
    s.split(/(http)/).reject { |x| x.blank? }.each_slice(2) { |s| b << s.join }
    b
  end

  def run_show_callbacks
    process_notice_viewer_request unless current_user.nil?
  end

  def process_notice_viewer_request
    # Only notice viewers
    return unless current_user.role?(Role.notice_viewer)
    # Only when the views limit is set for a user
    return unless current_user.notice_viewer_views_limit.present?
    # No need to update the counter when the limit is reached
    return if current_user.notice_viewer_viewed_notices >= current_user.notice_viewer_views_limit

    current_user.increment!(:notice_viewer_viewed_notices)
  end

  def show_html(format)
    format.html do
      show_render_html
    end
  end

  def show_json(format)
    format.json do
      render json: @notice,
             serializer: NoticeSerializerProxy,
             root: json_root_for(@notice.class)
    end
  end

  def show_render_html
    if @notice.rescinded?
      render :rescinded
    elsif @notice.hidden
      render file: 'public/404_hidden',
             formats: [:html],
             status: :not_found,
             layout: false
    elsif @notice.spam || !@notice.published
      render file: 'public/404_unavailable',
             formats: [:html],
             status: :not_found,
             layout: false
    else
      render :show
      run_show_callbacks
    end
  end
end
