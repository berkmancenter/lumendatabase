toggleFirstTimeContent = ->
  # This is to ensure that the contextualizing language does not exist in the 
  # DOM, otherwise google would assume it's extremely important content on 
  # every notice page and mess up relevancy ranking.
  if $('.first-time-visitor').text().length < 30
    $('.first-time-visitor').prepend(
      $('.first-time-visitor').data('content')
    )

  $('.first-time-visitor').slideToggle
    duration: 'fast'
    easing: 'easeOutCirc'
    complete: ->
      $.cookie('returning-visitor', 'returning', { expires: 365 } )

$ ->
  if typeof($.cookie('returning-visitor')) == 'undefined'
    toggleFirstTimeContent()

$('#hide-first-time-visitor-content a').click ->
  toggleFirstTimeContent()

$('.other-entities li').hover (->
  id = $(this).attr('data-id')
  $(".#{id}").removeClass('hide')
), ->
  id = $(this).attr('data-id')
  $(".#{id}").addClass('hide')
