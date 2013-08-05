$('form[action="/notices/search"]:not("#facets-form")').on 'submit', ->
  $(this)
    .find('[name="search-field"],[name="search-term"]')
    .attr('disabled','disabled')

updateRows = (field, value) ->
  $rows = new AdvancedSearchRows field, value
  activatedFieldGroup = $rows.activatedField()
  $rows.setActivatedFieldValue()
  $rows.ensureFieldOptionsExist()
  $rows.removeFieldOptionsFromOtherDropdowns()
  $(activatedFieldGroup).removeClass('hidden')
  $rows.resetTemplateRow()
  $rows.enableRowsWithValues()

$('#duplicate-field').on 'click', ->
  field = $(this).prev().find('select').val()
  value = $(this).prev().find('input[type="text"]').val()

  updateRows(field, value)

$('.field-group:not(.template-row) select').on 'change', ->
  newInputName = $(this).val()
  fieldGroup = $(this).closest('.field-group')
  oldInputName = $(fieldGroup).find('input').attr('name')
  value = $(fieldGroup).find('input').val()
  optionClone = $('.advanced-search')
    .find("option[value='#{oldInputName}']").first().clone()

  $(fieldGroup).removeClass(oldInputName).addClass(newInputName)
  $(fieldGroup).find('input').attr('name', newInputName)

  $rows = new AdvancedSearchRows newInputName, value
  $rows.ensureFieldOptionsExist()
  $rows.removeFieldOptionsFromOtherDropdowns()
  $rows.enableRowsWithValues()
  $rows.templateRow().find('select').prepend(optionClone)

$('.advanced-search').on 'click', '.remove-group', ->
  $fieldGroup = $(event.target).parent()
  field = $fieldGroup.find('input[type="text"]').attr('name')
  option = $fieldGroup.find("option[value='#{field}']")
  $('.field-group:last select').prepend(option)
  $fieldGroup.find('input,select').attr('disabled','disabled')
  $fieldGroup.addClass('hidden')
  $('.field-group.template-row,#duplicate-field').show()

correctAdvancedSearchDropdowns = ->
  $rows = new AdvancedSearchRows()
  $rows.enableRowsWithValues()
  $rows.removeOptionsforActiveRows()

$ ->
  correctAdvancedSearchDropdowns()
