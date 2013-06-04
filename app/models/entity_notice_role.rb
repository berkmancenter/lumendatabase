class EntityNoticeRole < ActiveRecord::Base
  belongs_to :entity
  belongs_to :notice

  ROLES = %w[principal agent recipient submitter target]

  class << self
    ROLES.each do |role|
      define_method(role.pluralize.to_sym) do
        where(name: role)
      end
    end
  end

  validates_inclusion_of :name, in: ROLES

end
