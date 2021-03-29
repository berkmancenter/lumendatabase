toggleAdvancedSearch = (duration) ->
  $('.container.advanced-search').slideToggle
    duration: duration
    easing: 'easeOutCirc'
    complete: ->
      $.cookie('advanced_search_visibility',
        $('.container.advanced-search').filter(':visible').length,
        { expires: 365 }
      )

hasAdvancedFieldActive = () ->
  fields_data = $('.search-field-data').map (_, elem) -> $(elem).data()

  hasFields = false
  for field in fields_data
    if field.value && field.parameter != 'term'
      hasFields = true

  return hasFields

$('#toggle-advanced-search').on 'click', ->
  toggleAdvancedSearch('fast')

$ ->
  if $.cookie('advanced_search_visibility') == "1" || hasAdvancedFieldActive()
    toggleAdvancedSearch(0)
