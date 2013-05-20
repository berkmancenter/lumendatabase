module Api
  class SubmissionsController < ApplicationController

    rescue_from(ActiveRecord::RecordInvalid) do |exception|
      record = exception.record
      error_messages = record.errors.full_messages.join ', '
      render text: error_messages, status: :bad_request
    end

    def create
      Submission.create!(submission_params)

      head :created
    end

    private

    def submission_params
      params.require(:submission).permit(:title, :file)
    end
  end

end
