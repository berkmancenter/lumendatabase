class NoticeSubmissionFinalizer
  delegate :errors, to: :notice

  def initialize(notice, parameters)
    @notice = notice
    @parameters = parameters
  end

  def finalize
    parameters[:submission_id] = notice.id
    notice.works.delete(SubmitNotice::PLACEHOLDER_WORKS)
    notice.update_attributes(parameters)
  end

  private

  attr_reader :parameters
  attr_accessor :notice
end
