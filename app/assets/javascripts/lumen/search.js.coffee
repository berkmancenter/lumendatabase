$rows = new AdvancedSearchRows()

$('form[action="/notices/search"]:not("#facets-form")').on 'submit', ->
  $(this)
    .find('[name="search-field"],[name="search-term"]')
    .attr('disabled','disabled')

$('#duplicate-field').on 'click', ->
  $rows.addField()

$('.advanced-search').on 'change', '.field-group select', (event) ->
  fieldGroup = $(this).closest('.field-group')
  $rows.fieldChanged(fieldGroup)

$('.advanced-search').on 'click', '.remove-group', (event) ->
  fieldGroup = $(this).closest('.field-group')
  $rows.removeField(fieldGroup)

$('.results-context-toggle').click ->
  $('.results-context').slideToggle
    duration: 'fast'
    easing: 'easeOutCirc'

$('#term-exact-search').on 'change', ->
  searchTerm = $('#search').val()
  searchTermArray = Array.from(searchTerm)

  if $('#term-exact-search').is(':checked')
    if searchTermArray[0] != '"' && searchTermArray.at(-1) != '"'
      $('#search').val('"' + searchTerm + '"')
  else
    if searchTermArray[0] == '"' && searchTermArray.at(-1) == '"'
      $('#search').val(searchTermArray.slice(1, -1).join(''))

$('#search').on 'change', ->
  searchTerm = $('#search').val()
  searchTermArray = Array.from(searchTerm)

  if searchTermArray[0] == '"' && searchTermArray.at(-1) == '"'
    $('#term-exact-search, .term-exact-search-adv').prop('checked', true)
  else
    $('#term-exact-search, .term-exact-search-adv').prop('checked', false)

$ ->
  $rows.displayActiveFields()
