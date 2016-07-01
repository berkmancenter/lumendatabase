require 'validates_automatically'

class EntityNoticeRole < ActiveRecord::Base
  include ValidatesAutomatically

  validates :name, length: { maximum: 255 }
  
  belongs_to :entity
  belongs_to :notice, touch: true

  default_scope { includes(:entity) }

  ROLES = %w(
    principal
    agent
    attorney
    recipient
    sender
    submitter
    target
    issuing_court
    plaintiff
    defendant
  )

  accepts_nested_attributes_for :entity

  def validate_associated_records_for_entity
    return unless entity.present?

    if existing_entity = Entity.where(entity.attributes_for_deduplication).first
      self.entity = existing_entity
    else
      # Since all validations are run before all inserts, the above does
      # not handle the same new entity appearing twice in one create
      # (earlier records have not been inserted when later records are
      # validated). To support this, we explicitly save the records as
      # part of validation. There is a small and accepted risk of
      # unnecessary saves and/or orphan entities.
      entity.save
    end
  end

  def name_enum
    ROLES
  end

  class << self
    ROLES.each do |role|
      define_method(role.pluralize.to_sym) do
        where(name: role)
      end
    end
  end

  validates_inclusion_of :name, in: ROLES
  validates_presence_of :entity, :notice
  validates_associated :entity

end
