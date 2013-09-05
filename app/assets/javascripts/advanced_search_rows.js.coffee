class @AdvancedSearchRows
  constructor: ->
    @_taken = []
    @_fields = $('.search-field-data').map (_, elem) -> $(elem).data()
    @_addMore = $('#duplicate-field')

  displayActiveFields: ->
    noParameters = true

    for field in @_fields
      if field.value
        noParameters = false

        @_insertFieldGroup(field)
        @_disableLastFieldGroup()
        @_taken.push(field.parameter)

    if noParameters
      @_insertFieldGroup({})

    @_resetAddMore()

  addField: ->
    @_disableLastFieldGroup()
    @_insertFieldGroup({})
    @_resetAddMore()

  removeField: (fieldGroup) ->
    name = fieldGroup.find('input[type="text"]').attr('name')

    fieldGroup.remove()

    @_release(name)
    @_resetAddMore(true)

  fieldChanged: (fieldGroup) ->
    input = fieldGroup.find('input[type="text"]')
    select = fieldGroup.find('select')

    if oldName = input.attr('name')
      fieldGroup.removeClass(oldName)
      @_release(oldName)

    newName = select.val()

    if newName == ''
      input.attr('name', null)
    else
      input.attr('name', newName)
      fieldGroup.addClass(newName)
      @_taken.push(newName)

  _disableLastFieldGroup: ->
    $('.field-group select').last().attr('disabled', 'disabled')

  _insertFieldGroup: (field) ->
    $('<div>')
      .addClass("field-group")
      .addClass(field.parameter)
      .append($('<div>').addClass('remove-group'))
      .append(@_buildSelect(field.parameter))
      .append(@_buildInput(field))
      .insertBefore(@_addMore)

  _buildSelect: (selected) ->
    select = $('<select>').attr('name', 'search-field')
      .append(@_buildOption({}))

    for field in @_fields
      if field.parameter not in @_taken
        option = @_buildOption(field)

        if field.parameter == selected
          option.attr('selected', true)

        select.append(option)

    $('<div>').addClass('input select').append(select)

  _buildOption: (field) ->
    $('<option>').val(field.parameter).text(field.title)

  _buildInput: (field) ->
    $('<input>').attr(type: 'text', name: field.parameter, value: field.value)

  _release: (name) ->
    index = @_taken.indexOf(name)
    @_taken.splice(index, 1)

  _resetAddMore: (forceShow) ->
    available = @_fields.length - @_taken.length

    if !forceShow && available <= 1
      @_addMore.hide()
    else
      @_addMore.show()
