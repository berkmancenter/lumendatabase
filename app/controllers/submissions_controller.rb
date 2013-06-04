class SubmissionsController < ApplicationController

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.new(submission_params)

    respond_to do |format|
      format.json { respond_for_api }
      format.html { respond_for_web }
    end
  end

  private

  def submission_params
    transform_html_parameters

    params.require(:submission).permit(*notice_params)
  end

  def notice_params
    [:title, :subject, :body, :date_received, :source, :file, :tag_list,
     category_ids: [], entities: entity_params, works: work_params]
  end

  def entity_params
    [:name, :kind, :role, :address_line_1, :address_line_2, :city, :state,
     :zip, :country_code, :phone, :email, :url]
  end

  def work_params
    [:url, :description, :kind, infringing_urls: []]
  end

  def respond_for_api
    if @submission.save
      render_created_submission(@submission)
    else
      render_bad_request(@submission.errors)
    end
  end

  def respond_for_web
    if @submission.save
      redirect_to :root, notice: "Notice added!"
    else
      render :new
    end
  end

  def render_created_submission(submission)
    render json: {
      notice_id: submission.notice_id,
      notice_url: notice_url(submission.notice_id)
    }, status: :created
  end

  def render_bad_request(errors)
    error_message = errors.full_messages.join(', ')

    render text: error_message, status: :bad_request
  end

  def transform_html_parameters
    if html_format?
      NormalizesParameters.normalize(params)
    end
  end

  def html_format?
    request.format.html?
  end

end
