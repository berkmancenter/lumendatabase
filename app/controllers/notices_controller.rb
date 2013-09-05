class NoticesController < ApplicationController
  layout :resolve_layout

  before_filter :authenticate_via_token, only: :create

  def new
    if params[:type].blank?
      render :select_type and return
    end

    model_class = get_notice_type(params)

    @notice = model_class.new
    @notice.file_uploads.build(kind: 'original')
    model_class::DEFAULT_ENTITY_NOTICE_ROLES.each do |role|
      @notice.entity_notice_roles.build(name: role).build_entity(
        kind: default_kind_based_on_role(role)
      )
    end
    @notice.works.build do |notice|
      notice.copyrighted_urls.build
      notice.infringing_urls.build
    end
  end

  def create
    submission = SubmitNotice.new(
      get_notice_type(params[:notice]),
      notice_params
    )

    respond_to do |format|
      format.json do
        if cannot?(:submit, Notice)
          head :unauthorized and return
        end

        if submission.submit(current_user)
          head :created, location: submission.notice
        else
          render json: submission.errors, status: :unprocessable_entity
        end
      end

      format.html do
        if submission.submit
          redirect_to :root, notice: "Notice created!"
        else
          @notice = submission.notice
          render :new
        end
      end
    end
  end

  def show
    @notice = Notice.find_visible(params[:id])

    respond_to do |format|
      format.html do
        if @notice.rescinded?
          render :rescinded
        else
          render :show
        end
      end

      format.json do
        render json: @notice, serializer: NoticeSerializerProxy,
          root: json_root_for(@notice.class)
      end
    end
  end

  private

  def json_root_for(klass)
    klass.to_s.tableize.singularize
  end

  def notice_params
    params.require(:notice).permit(
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
      category_ids: [],
      file_uploads_attributes: [:kind, :file, :file_name],
      entity_notice_roles_attributes: [
        :entity_id,
        :name,
        entity_attributes: entity_params
      ],
      works_attributes: work_params
    )
  end

  def entity_params
    [:name, :kind, :address_line_1, :address_line_2, :city, :state,
     :zip, :country_code, :phone, :email, :url]
  end

  def work_params
    [
      :description, :kind, infringing_urls_attributes: [:url],
      copyrighted_urls_attributes: [:url],
    ]
  end

  def resolve_layout
    case action_name
    when "show"
      "search"
    else
      "application"
    end
  end

  def get_notice_type(params)
    notice_type = params.fetch(:type, 'dmca').classify.constantize

    if notice_type < Notice
      notice_type
    else
      Dmca
    end

  rescue NameError
    Dmca
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
end
