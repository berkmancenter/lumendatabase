$ ->
  if $('.captcha-gateway')
    checkFormCaptchaReady = setInterval ->
      if $('#g-recaptcha-response-data-gateway').val()
        $('#captcha-gateway-form').submit()
        clearInterval(checkFormCaptchaReady)
    , 100
