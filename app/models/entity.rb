class Entity < ActiveRecord::Base
  has_ancestry orphan_strategy: :restrict
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles

  KINDS = %w[organization individual]

  validates_presence_of :name, :kind
  validates_inclusion_of :kind, in: KINDS
end
