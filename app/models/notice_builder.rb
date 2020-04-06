class NoticeBuilder
  def initialize(model_class, params, user=nil)
    @model_class = model_class
    @params = params
    @user = user
  end

  def build
    @notice = model_class.new(params)
    set_all_entities
    add_defaults
    @notice.auto_redact
    @notice
  end

  private
  attr_reader :model_class, :params, :user

  def add_defaults
    @notice.title = generic_title unless @notice.title.present?
    @notice.file_uploads.map do |file|
      file.kind = 'supporting' if file.kind.nil?
    end
  end

  def generic_title
    if recipient_name.present?
      "#{model_class.label} notice to #{recipient_name}"
    else
      "#{model_class.label} notice"
    end
  end

  def recipient_name
    # We can't fetch this with .where() because objects have not yet been
    # persisted.
    @recipient_name ||= @notice.entity_notice_roles
                               .select { |x| x.name.to_sym == :recipient }
                               .first
                               &.entity
                               &.name
  end

  def set_all_entities
    return unless !!user && !!(entity = user.entity)

    set_entity(:submitter, entity) unless entity_present?(:submitter)
    set_entity(:recipient, entity) unless entity_present?(:recipient)
  end

  def set_entity(role_name, entity)
    @notice.entity_notice_roles << EntityNoticeRole.new(
      name: role_name, entity: entity
    )
  end

  def entity_present?(role_name)
    return false unless (attrs = params.symbolize_keys[:entity_notice_roles_attributes])

    attrs.map do
      |x| x.symbolize_keys[:name].to_sym == role_name
    end.any?
  end
end
