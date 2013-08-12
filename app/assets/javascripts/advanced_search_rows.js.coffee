class @AdvancedSearchRows
  constructor: (@field, @value) ->

  activeRows: ->
    $('.field-group:not(.hidden)')

  enableRowsWithValues: ->
    this.activeRows().find('input,select').attr('disabled',null)

  removeOptionsforActiveRows: ->
    activeFields = []
    $(this.activeRows()).each (index, element) ->
      if $(element).find('.remove-group').length > 0
        field = $(element).find('input').attr('name')
        $(".field-group:not('.#{field}')").find(
          "option[value='#{field}']"
        ).remove()

  templateRow: ->
    $('.field-group:last')

  resetTemplateRow: ->
    $(this.templateRow()).find('input[type="text"]').val('')
    $(this.templateRow()).find('select').val('')

  activatedField: ->
    $('.advanced-search').find('.field-group.' + @field)

  ensureFieldOptionsExist: ->
    if $(this.activatedField()).find("option[value='#{@field}']").length == 0
      option = $(this.templateRow()).find("option[value='#{@field}']")
      $(this.activatedField()).find('select').prepend(option)

  setActivatedFieldValue: ->
    $(this.activatedField())
      .find('input[type="text"]')
      .attr('disabled', null).val(@value)

  removeFieldOptionsFromOtherDropdowns: ->
    $(".field-group:not('.#{@field}')").find(
      "option[value='#{@field}']"
    ).remove()

    if $(this.templateRow()).find('option').length == 0
      $('#duplicate-field').hide()
      $(this.templateRow()).hide()

