toggleEnterpriseReportRecipient = ->
  $status = $('#enterprise_account_report_frequency')
  $recipient = $('#enterprise-report-recipient')
  return unless $status.length && $recipient.length

  reportingOff = $status.val() == 'none'
  $recipient.toggle(!reportingOff).prop('hidden', reportingOff)
  $recipient.find('input').prop('disabled', reportingOff)

$ ->
  toggleEnterpriseReportRecipient()
  $(document).on 'change', '#enterprise_account_report_frequency', toggleEnterpriseReportRecipient
