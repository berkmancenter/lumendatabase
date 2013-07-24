$('#toggle-advanced-search').on 'click', ->
  $('.container.advanced-search').slideToggle
    duration: 'fast'
    easing: 'easeOutCirc'
$('#duplicate-field').on 'click', ->
  $field = $('.field-group:last')
  $clone = $field.clone()

  $(this).before($clone)
  $($clone).find('input').val('')
