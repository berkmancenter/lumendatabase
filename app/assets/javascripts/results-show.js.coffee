$('li.facet').on 'click', 'a', ->

  facet_hidden_input = $('input#' + $(this).attr('data-facet-name'))
  $(facet_hidden_input).val($(this).attr('data-value'))

  $parent = $(this).parent()
  $grandparent = $(this).parents('.dropdown')

  if $parent.hasClass('active')
    $parent.removeClass('active')
    $grandparent.removeClass('active')

  else
    $parent.addClass('active')
    $grandparent.addClass('active')

    ## Only allow one active child
    ## Remove all other active siblings
    $parent.siblings().each ->
      if $(this).hasClass('active')
        $(this).removeClass('active')

