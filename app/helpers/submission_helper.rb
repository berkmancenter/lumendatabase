module SubmissionHelper

  def entity_form_input(form, entity_type)
    output = ''
    output << form.input(
      :name,
      required: false,
      label: "#{entity_type} Name",
      input_html: {
        name: 'submission[entities][][name]',
        id: "submission_entities_#{entity_type.downcase}_name"
      }
    )
    output << form.input(
      :role,
      as: :hidden,
      input_html: {
        value: entity_type.downcase,
        name: 'submission[entities][][role]'
      }
    )
  end
end
