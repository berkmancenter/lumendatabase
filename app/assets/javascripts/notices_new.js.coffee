addFileUploadInput = (field, parent, updateContainer) ->
  containers = parent.find(".notice_file_uploads_#{field}")

  nextId = "notice_file_uploads_attributes_#{containers.length}_#{field}"
  nextName =  "notice[file_uploads_attributes][#{containers.length}][#{field}]"

  container = containers.last()
  newContainer = container.clone()

  updateContainer(newContainer, nextId, nextName)

  newContainer.insertAfter(container)

$('#new_notice select').each ->
  $(this).select2
    placeholder: ''
    width: 'off'

$('#notice_date_sent').datepicker
  format: 'yyyy-mm-dd'

$('#notice_date_received').datepicker
  format: 'yyyy-mm-dd'

$('.attach #add-another').click ->
  parent = $(this).parent()

  addFileUploadInput 'file', parent, (newContainer, nextId, nextName) ->
    newContainer.find('input').attr('id', nextId).attr('name', nextName)
    newContainer.find('label').attr('for', nextId).html('Other Documents')

  addFileUploadInput 'kind', parent, (newContainer, nextId, nextName) ->
    newContainer.find('input').attr('id', nextId).attr('name', nextName).attr('value', 'supporting')


toggleReportNoticePanels = ->
  $list = $('.notices-list ul')
  $info = $('.info-panel')

  el.children().first().addClass("active") for el in [$list, $info]
  $list.find('li').on "click", ->
    unless $(this).hasClass('active')
      id = $(this).attr('data-id')
      $(this).addClass('active').siblings().removeClass('active')
      $info.find("[data-id='#{id}']").addClass('active').siblings().removeClass('active')

toggleReportNoticePanels()


