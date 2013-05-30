module SubmissionHelper

  def entity_form_input(form, entity_type)
    output = ''
    [
      :name, :address_line_1, :address_line_2, :city, :state, :zip,
      :country_code, :phone, :email, :url
    ].each do |field_name|

      output << form.input(
        field_name,
        required: false,
        label: "#{entity_type} #{field_name.to_s.titleize}",
        input_html: {
          name: "submission[entities][][#{field_name}]",
          id: "submission_entities_#{entity_type.downcase}_#{field_name}"
        }
      )
    end

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
