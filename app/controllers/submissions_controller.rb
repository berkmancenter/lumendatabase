class SubmissionsController < ApplicationController

  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.new(submission_params)

    respond_to do |format|
      if @submission.save
        format.json { head :created }
        format.html { redirect_to :root, notice: "Notice added!" }
      else
        format.json { render_bad_request(@submission.errors) }
        format.html { render :new }
      end
    end
  end

  private

  def submission_params
    params.require(:submission).permit(
      :title, :body, :date_received, :file, :tag_list, category_ids: [], entities: [:name, :role]
    )
  end

  def render_bad_request(errors)
    error_message = errors.full_messages.join(', ')

    render text: error_message, status: :bad_request
  end

end
