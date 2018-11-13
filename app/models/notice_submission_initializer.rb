# This performs initial steps of the Notice submission process: creating a
# new Notice with enough of the provided attributes that it can be persisted.
# Where persisting attributes is slow, those can be deferred to the
# NoticeSubmissionFinalizer.
class NoticeSubmissionInitializer
  delegate :errors, to: :notice

  # Notice validates the presence of works, but we delay adding works because
  # it is too time-consuming for the request/response cycle. Therefore we
  # need to add a placeholder so the Notice instance can save.
  PLACEHOLDER_WORKS = [Work.unknown].freeze

  def initialize(model_class, parameters)
    @model_class = model_class
    @parameters = parameters
  end

  def submit(user = nil)
    set_all_entities(user)

    add_notice_defaults

    return false unless notice.save

    notice.mark_for_review
    true
  end

  def add_notice_defaults
    notice.title = generic_title unless notice.title.present?
    notice.works = PLACEHOLDER_WORKS
    notice.file_uploads.map do |file|
      file.kind = 'supporting' if file.kind.nil?
    end
    notice.auto_redact
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
