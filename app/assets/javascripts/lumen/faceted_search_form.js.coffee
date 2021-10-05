closestDropdown = (el) ->
  el.closest('.dropdown-menu')

clearUnspecifiedInputs = (el) ->
  closestDropdown(el).siblings('input.unspecified').val('')

parentActive = (el) ->
  return el.parent().hasClass('active')

otherActive = (el) ->
  something_active = closestDropdown(el).find('.active').length > 0
  return something_active && !parentActive(el)

$('ol.results-facets li.facet').on 'click', 'a', (event) ->
  event.preventDefault()
  clearUnspecifiedInputs($(this))

  facet_name = $(this).attr('data-facet-name')
  facet_value = $(this).attr('data-value')
  facet_hidden_input = $("input##{facet_name}")
  hidden_unspecified_indicator = $("input##{$(this).data('unspecified-name')}")

  if (!parentActive($(this)) && facet_hidden_input.val() != facet_value) || otherActive($(this))
    facet_hidden_input.val(facet_value)
    if facet_value == undefined
      hidden_unspecified_indicator.val(true)
    $('form#facets-form').submit()

clearEmptyParameters = ->
  $('form#facets-form').find('input[type="hidden"]').each (_, element) ->
    if $(element).val() == ''
      $(element).remove()

createHiddenTermInput = (term, value) ->
  term_input = $('<input />')
    .attr({'type': 'hidden', 'name': term, 'value': value})

cloneGlobalSearch = (context) ->
  value = $('input#search').val()
  term_input = createHiddenTermInput('term', value)
  $(context).append(term_input)

cloneAdvancedSearch = (context) ->
  $('.field-group input').each (_, element) ->
    name = $(element).attr('name')
    value = $(element).val()

    unless $(element).is(":checkbox")
      term_input = createHiddenTermInput(name, value)
    else if $(element).is(":checked")
      term_input = createHiddenTermInput(name, value)

    $(context).append(term_input)

$('form#facets-form').on 'submit', ->
  clearEmptyParameters()

  if $('.advanced-search:visible').length > 0
    cloneAdvancedSearch(this)
  else
    cloneGlobalSearch(this)

$('.sort-order ol.dropdown-menu a').click (event)->
  event.preventDefault()

  value = $(this).attr('data-value')
  sort_by_field = $('.sort_by_field')

  if sort_by_field.val() != value
    sort_by_field.val(value)
    $('form#facets-form').submit()
