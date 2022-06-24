$(document).on('pjax:complete', function(event, request) {
  edit_notice_form_actions();
});

$(document).ready(function () {
  edit_notice_form_actions();
});

function edit_notice_form_actions() {
  edit_notice_form = $(
    `form#edit_notice,
    form#edit_dmca,
    form#edit_counterfeit,
    form#edit_counternotice,
    form#edit_court_order,
    form#edit_data_protection,
    form#edit_defamation,
    form#edit_government_request,
    form#edit_law_enforcement_request,
    form#edit_private_information,
    form#edit_trademark,
    form#edit_other,
    form#edit_placeholder`
  );

  if (edit_notice_form.length) {
    var form_model_type = edit_notice_form.first().attr('id').replace('edit_', '');

    set_works_editor(form_model_type);
    set_taggings_editor(form_model_type);
  }
}

function set_works_editor(form_model_type) {
  var field_name = `${form_model_type}_works_json`;

  var editor = new JSONEditor(document.querySelector(`#${field_name}_field > div`), {
    disable_collapse: true,
    disable_edit_json: true,
    disable_properties: true,
    disable_array_reorder: true,
    disable_array_delete_last_row: true,
    theme: 'bootstrap4',
    schema: {
      'type': 'array',
      'items': {
        'title': 'work',
        'type': 'object',
        'properties': {
          'description': {
            'type': 'string'
          },
          'description_original': {
            'type': 'string'
          },
          'kind': {
            'type': 'string'
          },
          'infringing_urls': {
            'type': 'array',
            'format': 'table',
            'items': {
              'title': 'url',
              'type': 'object',
              'properties': {
                'url': {
                  'type': 'string'
                },
                'url_original': {
                  'type': 'string'
                }
              }
            }
          },
          'copyrighted_urls': {
            'type': 'array',
            'format': 'table',
            'items': {
              'title': 'url',
              'type': 'object',
              'properties': {
                'url': {
                  'type': 'string'
                },
                'url_original': {
                  'type': 'string'
                }
              }
            }
          }
        }
      }
    }
  });

  $(`#${field_name}, .works_json_field .help-block`).hide();

  editor.on('ready',() => {
    $('.works_json_field .card-title').first().hide();
    editor.setValue(JSON.parse($(`#${field_name}`).val()));
  });

  editor.on('change',() => {
    $(`#${field_name}`).html(JSON.stringify(editor.getValue()));
  });
}

function set_taggings_editor(form_model_type) {
  var list_types = ['tag', 'jurisdiction', 'regulation'];

  list_types.forEach(function (type) {
    var input_field_id = `${form_model_type}_${type}_list`;
    var field_id = `${type}_list_field`;

    var editor = new JSONEditor(document.querySelector(`#${input_field_id}_field > div`), {
      disable_collapse: true,
      disable_edit_json: true,
      disable_properties: true,
      disable_array_reorder: true,
      disable_array_delete_last_row: true,
      theme: 'bootstrap4',
      schema: {
        'type': 'array',
        'items': {
          'title': `${type}`,
          'type': 'string'
        }
      }
    });

    $(`#${input_field_id}, .${field_id} .help-block`).hide();

    editor.on('ready',() => {
      $(`.${field_id} .card-title`).first().hide();
      editor.setValue(JSON.parse($(`#${input_field_id}`).val()));
    });

    editor.on('change',() => {
      $(`#${input_field_id}`).val(JSON.stringify(editor.getValue()));
    });
  });
}
