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

$ ->
  $rows.displayActiveFields()
