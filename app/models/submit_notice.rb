class SubmitNotice

  delegate :errors, to: :notice

  def initialize(model_class, parameters)
    @model_class = model_class
    @parameters = parameters
  end

  def submit(user = nil)
    if user && (entity = user.entity)
      entity_present?('submitter') or set_entity('submitter', entity)
      entity_present?('recipient') or set_entity('recipient', entity)
    end

    notice.auto_redact

    if notice.save
      notice.mark_for_review
      true
    end
  end

  def notice
    @notice ||= model_class.new(parameters)
  end

  private

  attr_reader :model_class, :parameters

  def set_entity(role_name, entity)
    parameters[:entity_notice_roles_attributes] ||= []
    parameters[:entity_notice_roles_attributes] << {
      name: role_name,
      entity_id: entity.id
    }
  end

  def entity_present?(role_name)
    roles = parameters.fetch(:entity_notice_roles_attributes, [])
    roles.any? { |role| role[:name] == role_name }
  end

end
