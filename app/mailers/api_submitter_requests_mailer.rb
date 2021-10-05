class ApiSubmitterRequestsMailer < ApplicationMailer
  def api_submitter_request_approved(user)
    api_submitter_request_result(user)
  end

  def api_submitter_request_rejected(user)
    api_submitter_request_result(user)
  end

  private

  def api_submitter_request_result(user)
    @user = user

    subject = 'Submitter plugin access request'

    mail(
      to: user.email,
      subject: subject
    )
  end
end
