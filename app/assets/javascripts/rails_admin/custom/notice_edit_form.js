$(document).on('pjax:complete', function(event, request) {
  edit_notice_form_actions();
});

$(document).ready(function () {
  edit_notice_form_actions();
});

function edit_notice_form_actions() {
  edit_notice_form = $('form#edit_notice');

  if (edit_notice_form.length) {
    set_works_editor();
  }
}

function set_works_editor() {
  var editor = new JSONEditor(document.querySelector('#notice_works_json_field > div'), {
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

  $('#notice_works_json, .works_json_field .help-block').hide();

  editor.on('ready',() => {
    $('.works_json_field .card-title').first().hide();
    editor.setValue(JSON.parse($('#notice_works_json').val()));
  });

  editor.on('change',() => {
    $('#notice_works_json').html(JSON.stringify(editor.getValue()));
  });
}
