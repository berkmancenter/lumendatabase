$("#relevant-questions").collapse
  query: '.question'
  open: ->
    @slideDown 200, 'easeOutQuad'
  close: ->
    @slideUp 200, 'easeOutQuad'

$("#category-faqs").collapse
  query: '.question'
  open: ->
    @slideDown 200, 'easeOutQuad'
  close: ->
    @slideUp 200, 'easeOutQuad'
