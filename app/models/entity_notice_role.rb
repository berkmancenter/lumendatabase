require 'validates_automatically'

class EntityNoticeRole < ActiveRecord::Base
  include ValidatesAutomatically
  belongs_to :entity
  belongs_to :notice, touch: true

  ROLES = %w[principal agent recipient submitter target]

  accepts_nested_attributes_for :entity

  def validate_associated_records_for_entity
    if self.entity && existing_entity = Entity.where(
      name: self.entity.name
    ).first
      self.entity = existing_entity
    end
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

end
