$(document).on('pjax:complete', function(event, request) {
  edit_user_form_actions();
});

$(document).ready(function () {
  edit_user_form_actions();
});

function edit_user_form_actions() {
  edit_user_form = $('form#edit_user');

  if (edit_user_form.length) {
    handle_can_generate_permanent_notice_token_urls();
  }
}

function handle_can_generate_permanent_notice_token_urls() {
  var can_perm_checkbox = $('#user_can_generate_permanent_notice_token_urls');
  var allow_perm_sensitive_checkbox = $('#user_allow_generate_permanent_tokens_researchers_only_notices');

  if (can_perm_checkbox.prop('checked') === false) {
    allow_perm_sensitive_checkbox.prop('disabled', true);
  }

  can_perm_checkbox.on('change', function () {
    if (can_perm_checkbox.prop('checked') === false) {
      allow_perm_sensitive_checkbox.prop('disabled', true);
      allow_perm_sensitive_checkbox.prop('checked', false);
    } else {
      allow_perm_sensitive_checkbox.prop('disabled', false);
    }
  });
}
