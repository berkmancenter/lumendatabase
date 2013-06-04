module SubmissionHelper

  def entity_form_input(form, entity_type)
    output = ''
    output << entity_form_field(form, :name, entity_type)
    output << form.input(
      :kind,
      required: false,
      label: "#{entity_type} Kind",
      collection: Entity::KINDS,
      prompt: nil,
      input_html: {
        name: "submission[entities][][kind]",
        id: "submission_entities_#{entity_type.downcase}_kind",
        value: "individual"
      }
    )

    [
      :address_line_1, :address_line_2, :city, :state, :zip,
      :country_code, :phone, :email, :url
    ].each do |field_name|

      output << entity_form_field(form, field_name, entity_type)
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

  private

  def entity_form_field(form, field_name, entity_type)
    form.input(
      field_name,
      required: false,
      label: "#{entity_type} #{field_name.to_s.titleize}",
      input_html: {
        name: "submission[entities][][#{field_name}]",
        id: "submission_entities_#{entity_type.downcase}_#{field_name}"
      }
    )
  end
end
