class EntityNoticeRole < ActiveRecord::Base
  belongs_to :entity
  belongs_to :notice

  ROLES = %w[principal agent recipient submitter target]

  validates_presence_of :entity, :notice, :name
  validates_inclusion_of :name, in: ROLES
end
