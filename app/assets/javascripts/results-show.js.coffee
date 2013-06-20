$('li.facet').on 'click', 'a', ->
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

