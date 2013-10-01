class SubmissionIdsController < RedirectingController
  def show
    super(Notice, :find_by_submission_id)
  end
end
