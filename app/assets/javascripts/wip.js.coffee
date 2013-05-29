$ ->
  $('html').keypress (e) ->
    codeForW = 23
    if e.ctrlKey and e.which is codeForW
      $('.wip').toggleClass('disabled')
