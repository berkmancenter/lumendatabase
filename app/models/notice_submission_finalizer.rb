class NoticeSubmissionFinalizer
  delegate :errors, to: :notice

  def initialize(notice, parameters)
    @notice = notice
    @parameters = parameters
  end

  def finalize
    notice.update_attributes(parameters)
    notice.works.delete(SubmitNotice::PLACEHOLDER_WORKS)
  end

  private

  attr_reader :parameters
  attr_accessor :notice
end
