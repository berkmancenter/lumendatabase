selectedField = null

class Redactable
  constructor: (@input) ->

  redactSelection: ->
    selectedText = @input.value.substring(
      @input.selectionStart, @input.selectionEnd
    )

    if selectedText
      @input.value = @input.value.replace(
        ///#{this._literal(selectedText)}///g, "[REDACTED]"
      )

      this._clearSelection()

  unredact: ->
    if originalInput = $("##{@input.id}_original")[0]
      @input.value = originalInput.value

  _literal: (text) ->
    text.replace /([\.\+\*\?\(\[\{\)\]\}])/g, '\\$1'

  _clearSelection: ->
    # prevent double redacting
    @input.selectionStart = 0
    @input.selectionEnd = 0

addHandlers = ->
  $("textarea").each (_, textarea) ->
    $(textarea).focus ->
      selectedField = new Redactable this

  $("button#redact-selected").click ->
    selectedField?.redactSelection()

  $("button#unredact-selected").click ->
    selectedField?.unredact()

$(document).ready -> addHandlers()
$(document).on 'pjax:end', -> addHandlers()
