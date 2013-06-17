$('#new_notice select').each ->
  $(this).select2
    placeholder: ''
    width: 'off'

$('#notice_date_received').datepicker
  format: 'yyyy-mm-dd'
