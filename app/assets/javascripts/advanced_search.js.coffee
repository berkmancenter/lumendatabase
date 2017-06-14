toggleAdvancedSearch = (duration) ->
  $('.container.advanced-search').slideToggle
    duration: duration
    easing: 'easeOutCirc'
    complete: ->
      $.cookie('advanced_search_visibility',
        $('.container.advanced-search').filter(':visible').length,
        { expires: 365 }
      )

$('#toggle-advanced-search').on 'click', ->
  toggleAdvancedSearch('fast')

$ ->
  if $.cookie('advanced_search_visibility') == "1" || ( typeof( active_advanced_search_parameters ) != 'undefined' && active_advanced_search_parameters )
    toggleAdvancedSearch(0)
