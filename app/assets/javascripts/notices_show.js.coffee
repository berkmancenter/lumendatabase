$('.other-entities li').hover (->
  id = $(this).attr('data-id')
  $(".#{id}").removeClass('hide')
), ->
  id = $(this).attr('data-id')
  $(".#{id}").addClass('hide')
