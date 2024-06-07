class UpdateSubmitterWidgetTranslations < ActiveRecord::Migration[7.1]
  def change
    Translation
      .find_by(key: 'submitter_widget_notice_new_roles_info')
      .update(body: '<p>Enter information about the <b>%{role}</b> of the %{label}.</p>')

    Translation
      .create(
        key: 'submitter_widget_notice_new_roles_info_header',
        body: '<h4><span>Step %{step_number}.</span> %{role_header_title} of the Notice</h4>'
      )
  end
end
