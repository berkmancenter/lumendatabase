class AssociatesEntities

  def initialize(entity_params, notice, submission)
    @entity_params = entity_params
    @notice = notice
    @submission = submission
  end

  def associate
    if entities_to_associate?
      @entity_params.map do|entity_param|
        entity = Entity.new(valid_entity_params(entity_param))
        @submission.models << entity
        @submission.models << EntityNoticeRole.new(
          notice: @notice,
          entity: entity,
          name: entity_param[:role]
        )
      end
    end
  end

  private

  def valid_entity_params(entity)
    entity.slice(
      :name, :kind, :address_line_1, :address_line_1, :address_line_2,
      :city, :state, :zip, :country_code, :phone, :email, :url
    )
  end

  def entities_to_associate?
    @entity_params.present? &&
      @entity_params.all? do |entity|
        entity[:name].present? && entity[:role].present?
      end
  end
end
