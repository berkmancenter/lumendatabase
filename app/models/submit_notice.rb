class SubmitNotice
  attr_reader :notice

  delegate :errors, to: :notice

  def initialize(model_class, parameters)
    @notice = model_class.new(parameters)
  end

  def submit
    notice.auto_redact

    if notice.save
      notice.mark_for_review
      true
    end
  end
end
