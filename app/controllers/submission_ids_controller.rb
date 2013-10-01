class SubmissionIdsController < ApplicationController
  def show
    notice = Notice.find_by_submission_id(params[:id])

    if notice
      redirect_to(notice_path(notice), status: :moved_permanently)
    else
      render nothing: true, status: :not_found
    end
  end
end
