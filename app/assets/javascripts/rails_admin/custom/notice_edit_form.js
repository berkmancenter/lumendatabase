class NoticeEditForm {
  notice_edit_form_default_editor_params = {
    disable_collapse: true,
    disable_edit_json: true,
    disable_properties: true,
    disable_array_reorder: true,
    disable_array_delete_last_row: true,
    theme: 'bootstrap4'
  };

  constructor() {
    let that = this;

    $(document).on('pjax:complete', function(event, request) {
      that.notice_form_actions();
    });

    $(document).ready(function () {
      that.notice_form_actions();
    });
  }

  notice_form_actions() {
    let forms = ['new', 'edit'];
    let notice_types = ['notice', 'dmca', 'counterfeit', 'counternotice', 'court_order',
      'data_protection', 'defamation', 'government_request', 'law_enforcement_request',
      'private_information', 'trademark', 'other', 'placeholder'
    ];

    let selectors = '';
    forms.forEach(function (val_form) {
      notice_types.forEach(function (val_type) {
        selectors += `form#${val_form}_${val_type},`;
      });
    });
    selectors = selectors.slice(0, -1);

    let notice_form = $(selectors);

    if (notice_form.length) {
      this.form_model_type = notice_form.first().attr('id').replace('edit_', '').replace('new_', '');

      this.set_works_editor();
      this.set_taggings_editor();
      this.set_customizations_editor();
    }
  }

  set_works_editor() {
    let field_name = `${this.form_model_type}_works_json`;

    let editor = new JSONEditor(document.querySelector(`#${field_name}_field > div`), {
      ...this.notice_edit_form_default_editor_params,
      required_by_default: true,
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
      let val_to_init = $(`#${field_name}`).val();
      if (!val_to_init) {
        val_to_init = '[]';
      }
      editor.setValue(JSON.parse(val_to_init));
    });

    editor.on('change',() => {
      $(`#${field_name}`).html(JSON.stringify(editor.getValue()));
    });
  }

  set_taggings_editor() {
    let that = this;
    let list_types = ['tag', 'jurisdiction', 'regulation'];

    list_types.forEach(function (type) {
      let input_field_id = `${that.form_model_type}_${type}_list`;
      let field_id = `${type}_list_field`;

      let editor = new JSONEditor(document.querySelector(`#${input_field_id}_field > div`), {
        ...that.notice_edit_form_default_editor_params,
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
        let val_to_init = $(`#${input_field_id}`).val();
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

  set_customizations_editor() {
    let field_name = `${this.form_model_type}_customizations`;

    let editor = new JSONEditor(document.querySelector(`#${field_name}_field > div`), {
      ...this.notice_edit_form_default_editor_params,
      required_by_default: true,
      schema: {
        'type': 'object',
        'properties': {
          'hide_works': {
            'title': 'Hide works',
            'type': 'boolean',
            'format': 'checkbox'
          },
          'body_field_label': {
            'title': 'Body field label',
            'type': 'string'
          },
          'static_works_text': {
            'title': 'Static text before works list',
            'type': 'string',
            'format': 'html'
          }
        }
      }
    });

    $(`#${field_name}, .customizations_field .help-block`).hide();

    editor.on('ready',() => {
      $('.customizations_field .card-title').first().hide();
      let val_to_init = $(`#${field_name}`).val();
      if (!val_to_init) {
        val_to_init = '{}';
      }
      editor.setValue(JSON.parse(val_to_init));
    });

    editor.on('change',() => {
      $(`#${field_name}`).html(JSON.stringify(editor.getValue()));
    });
  }
}

new NoticeEditForm();
