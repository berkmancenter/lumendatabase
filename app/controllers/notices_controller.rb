class NoticesController < ApplicationController

  def new
    @notice = Notice.new
    @notice.file_uploads.build
    @notice.entity_notice_roles.build(name: 'recipient').build_entity
    @notice.entity_notice_roles.build(name: 'sender').build_entity
    @notice.works.build.infringing_urls.build
  end

  def create
    @notice = Notice.new(notice_params)
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
      format.html
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
      category_ids: [],
      file_uploads_attributes: [:file],
      entity_notice_roles_attributes: [
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
    [:url, :description, :kind, infringing_urls_attributes: [:url]]
  end

end
