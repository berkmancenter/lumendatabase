require 'validates_automatically'

class Entity < ActiveRecord::Base
  include ValidatesAutomatically
  has_ancestry orphan_strategy: :restrict
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles

  KINDS = %w( organization individual )

  ADDRESS_FIELDS = %i(
    address_line_1 address_line_2 city state zip country_code
  )

  validates_inclusion_of :kind, in: KINDS
  validates_uniqueness_of :name

  after_update { notices.each(&:touch) }

  def addressed?
    ADDRESS_FIELDS.any? { |field| send(field).present? }
  end

end
