class SubmitNotice
  delegate :errors, to: :notice

  def initialize(model_class, parameters)
    @model_class = model_class
    @parameters = parameters
  end

  def submit(user = nil)
    set_all_entities(user)
    notice.title = generic_title unless notice.title.present?
    notice.auto_redact

    return unless notice.save

    notice.mark_for_review
    notice.copy_id_to_submission_id
    true
  end

  def notice
    @notice ||= model_class.new(
      if parameters.class == Hash
        parameters
      else
        parameters.permit!
      end
    )
  end

  private

  attr_reader :model_class, :parameters

  def set_entity(role_name, entity)
    parameters[:entity_notice_roles_attributes] ||= []
    flatten_param(parameters[:entity_notice_roles_attributes]) << {
      name: role_name,
      entity_id: entity.id
    }
  end

  def set_all_entities(user)
    return unless user && (entity = user.entity)
    set_entity('submitter', entity) unless entity_present?('submitter')
    set_entity('recipient', entity) unless entity_present?('recipient')
  end

  def recipient_name
    entity_name('recipient')
  end

  def generic_title
    if recipient_name.present?
      "#{model_class.label} notice to #{recipient_name}"
    else
      "#{model_class.label} notice"
    end
  end

  def entity_name(role_name)
    role = entity_notice_role(role_name)

    return unless role.present?
    if role.key?(:entity_attributes)
      role[:entity_attributes][:name]
    elsif role.key?(:entity_id)
      Entity.find(role[:entity_id]).name
    end
  end

  def entity_present?(role_name)
    entity_notice_role(role_name).present?
  end

  def entity_notice_role(role_name)
    roles = flatten_param(parameters[:entity_notice_roles_attributes])
    roles.detect { |role| role[:name] == role_name }
  end

  # JSON API submissions:
  #
  #   [{ ... }, { ... }, { ... }]
  #
  # Rails form submissions:
  #
  #   { '0' => { ... }, '1' => { ... }, '3' => { ... } }
  #
  # This flattens the second style to the first, IFF it's not that way
  # already. Curse you, Rails for making me type-check.
  def flatten_param(param)
    case param
    when Hash  then param.values
    when Array then param
    else []
    end
  end
end
