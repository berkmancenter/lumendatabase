addFileUploadInput = (field, parent, updateContainer) ->
  containers = parent.find(".notice_file_uploads_#{field}")
  console.log(containers.length)

  nextId = "notice_file_uploads_attributes_#{containers.length}_#{field}"
  nextName =  "notice[file_uploads_attributes][#{containers.length}][#{field}]"

  container = containers.last()
  newContainer = container.clone()

  updateContainer(newContainer, nextId, nextName)

  newContainer.appendTo($('#file_uploads_inputs'))

$('.new_notice select').each ->
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
    newContainer.find('label').attr('for', nextId).html('Additional document')

  addFileUploadInput 'kind', parent, (newContainer, nextId, nextName) ->
    newContainer.find('select').attr('id', nextId).attr('name', nextName).attr('value', 'supporting')
    newContainer.find('label').attr('for', nextId).html('Document type')

$(document).on 'click', '.add-another-url', ->
  anchor = $(this)
  $.get(anchor.data('target'), (text) ->
    input = $(text)
    input.append($('<button class="remove-url">X</button>'))
    anchor.after(input)
    if $('#notice_url_count').length > 0
      $('#notice_url_count').val(anchor.closest('section').find('.input.url').length)
  ).fail ->
    alert("We're sorry, an error occurred.")

$(document).on 'click', '.remove-url', ->
  section = $(this).closest('section')
  $(this).parent().remove()
  if $('#notice_url_count').length > 0
    $('#notice_url_count').val(section.find('.input.url').length)


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
