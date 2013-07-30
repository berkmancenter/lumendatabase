toggleAdvancedSearch = (duration) ->
  $('.container.advanced-search').slideToggle
    duration: duration
    easing: 'easeOutCirc'
    complete: ->
      $.cookie('advanced_search_visibility',
        $('.container.advanced-search').filter(':visible').length,
        { expires: 365 }
      )

if $.cookie('advanced_search_visibility') == "1"
  toggleAdvancedSearch(0)

$('form[action="/notices/search"]').on 'submit', ->
  $(this).find('[name="search-field"],[name="search-term"]').remove()

$('#toggle-advanced-search').on 'click', -> 
  toggleAdvancedSearch('fast')

$('#duplicate-field').on 'click', ->
  $field = $('.field-group:last')
  # So - we need to find the hidden field, remove the hidden class, set the value
  # and "reset" the selector thing.

  selectedField = $(this).prev().find('select').val()
  selectedFieldQueryTerm = $(this).prev().find('input[type="text"]').val()
  activatedFieldGroup = $(this).parentsUntil('.advanced-search').find('.field-group.' + selectedField)

  $(activatedFieldGroup).find('input[type="text"]').val(selectedFieldQueryTerm)
  $(activatedFieldGroup).removeClass('hidden')

  $($field).find('input[type="text"]').val('')
  $($field).find('select').val('')

$('.advanced-search').on 'click', '.remove-group', ->
  $parent = $(event.target).parent()
  if $parent.siblings().hasClass('field-group')
    $parent.remove()
