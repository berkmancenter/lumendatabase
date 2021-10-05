$(document).ready(function () {
  document.querySelector('form').addEventListener('submit', function (e) {
    parentIFrame.scrollToOffset(0, -20);
  });

  var organizationFieldsSelector = '.notice_entity_notice_roles_entity_address_line_1, .notice_entity_notice_roles_entity_address_line_2, .notice_entity_notice_roles_entity_city, .notice_entity_notice_roles_entity_state, .notice_entity_notice_roles_entity_zip, .notice_entity_notice_roles_entity_phone, .notice_entity_notice_roles_entity_email, .notice_entity_notice_roles_entity_url';
  $('.notice_entity_notice_roles_entity_kind select').on('change', function () {
    var elemValue = $(this).val();
    var roleElem = $(this).parents('.role').first();

    if (elemValue === 'organization') {
      roleElem.find(organizationFieldsSelector).show();
    } else if (elemValue === 'individual') {
      roleElem.find(organizationFieldsSelector).hide();
    }
  });
});
