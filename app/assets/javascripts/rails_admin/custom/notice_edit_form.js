$(document).on('pjax:complete', function(event, request) {
  notice_form_actions();
});

$(document).ready(function () {
  notice_form_actions();
});

function notice_form_actions() {
  var forms = ['new', 'edit'];
  var notice_types = ['notice', 'dmca', 'counterfeit', 'counternotice', 'court_order',
    'data_protection', 'defamation', 'goverment_request', 'law_enforcement_request',
    'private_information', 'trademark', 'other', 'placeholder'
  ];

  var selectors = '';
  forms.forEach(function (val_form) {
    notice_types.forEach(function (val_type) {
      selectors += `form#${val_form}_${val_type},`;
    });
  });
  selectors = selectors.slice(0, -1);

  var notice_form = $(selectors);

  if (notice_form.length) {
    var form_model_type = notice_form.first().attr('id').replace('edit_', '').replace('new_', '');

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
        'show_opt_in': true,
        'properties': {
          'description': {
            'type': 'string',
            'show_opt_in': true
          },
          'description_original': {
            'type': 'string',
            'show_opt_in': true
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
      var val_to_init = $(`#${input_field_id}`).val();
      if (!val_to_init) {
        val_to_init = '[]';
      }
      editor.setValue(JSON.parse(val_to_init));
    });

    editor.on('change',() => {
      $(`#${input_field_id}`).val(JSON.stringify(editor.getValue()));
    });
  });
}
