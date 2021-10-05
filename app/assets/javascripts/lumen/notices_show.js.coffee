toggleFirstTimeContent = ->
  # This is to ensure that the contextualizing language does not exist in the 
  # DOM, otherwise google would assume it's extremely important content on 
  # every notice page and mess up relevancy ranking.
  if $('.first-time-visitor .first-visitor-content').text().length < 30
    $('.first-time-visitor-content').append(
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

$('.first-time-visitor').click ->
  toggleFirstTimeContent()

$('.other-entities li').hover (->
  id = $(this).attr('data-id')
  $(".#{id}").removeClass('hide')
), ->
  id = $(this).attr('data-id')
  $(".#{id}").addClass('hide')

$(document).ready ->
  $('.document-original').click 'ajax:complete', (xhr, status) ->
    $(this).find('.download').html 'Document requested. Check back in 7 days.'
    return
  return
