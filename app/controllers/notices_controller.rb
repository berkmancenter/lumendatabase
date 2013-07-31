class NoticesController < ApplicationController
  layout :resolve_layout

  def new
    if params[:type].blank?
      render :select_type and return
    end

    model_class = get_notice_type(params)

    @notice = model_class.new
    @notice.file_uploads.build
    @notice.entity_notice_roles.build(name: 'recipient').build_entity
    @notice.entity_notice_roles.build(name: 'sender').build_entity
    @notice.works.build do |notice|
      notice.copyrighted_urls.build
      notice.infringing_urls.build
    end
  end

  def create
    model_class = get_notice_type(params[:notice])

    @notice = model_class.new(notice_params)
    @notice.auto_redact

    respond_to do |format|
      if @notice.save
        @notice.mark_for_review
        format.html { redirect_to :root, notice: "Notice created!" }
        format.json { head :created, location: @notice }
      else
        format.html { render :new }
        format.json do
          render json: @notice.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    @notice = Notice.find(params[:id])

    respond_to do |format|
      format.html do
        if @notice.rescinded?
          render :rescinded
        else
          render :show
        end
      end

      format.json { render json: @notice }
    end
  end

  private

  def notice_params
    params.require(:notice).permit(
      :title,
      :subject,
      :body,
      :legal_other,
      :date_sent,
      :date_received,
      :source,
      :tag_list,
      :jurisdiction_list,
      :language,
      :action_taken,
      category_ids: [],
      file_uploads_attributes: [:file],
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

end
