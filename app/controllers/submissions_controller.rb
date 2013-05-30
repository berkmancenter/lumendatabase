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
    params.require(:submission).permit(
      :title, :body, :date_received, :file, :tag_list, category_ids: [],
      entities: valid_entity_fields
    )
  end

  def respond_for_api
    @submission.source = :api

    if @submission.save
      head :created
    else
      render_bad_request(@submission.errors)
    end
  end

  def respond_for_web
    @submission.source = :web

    if @submission.save
      redirect_to :root, notice: "Notice added!"
    else
      render :new
    end
  end

  def render_bad_request(errors)
    error_message = errors.full_messages.join(', ')

    render text: error_message, status: :bad_request
  end

  def valid_entity_fields
    [:name, :role, :address_line_1, :address_line_2, :city, :state, :zip,
      :country_code, :phone, :email, :url]
  end

end
