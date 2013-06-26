require 'validates_automatically'

class Entity < ActiveRecord::Base
  include ValidatesAutomatically
  has_ancestry orphan_strategy: :restrict
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles

  KINDS = %w[organization individual]

  validates_inclusion_of :kind, in: KINDS
  validates_uniqueness_of :name

  after_update { notices.each(&:touch) }
end
