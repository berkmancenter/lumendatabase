require 'validates_automatically'

class Entity < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include ValidatesAutomatically

  PER_PAGE = 10
  HIGHLIGHTS = %i(name)

  has_ancestry orphan_strategy: :restrict
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles

  mapping do
    columns.map(&:name).reject{|name| name == 'id'}.each do|column_name|
      indexes column_name
    end
    indexes :parent_id, as: 'parent_id'
  end

  KINDS = %w[organization individual]

  validates_inclusion_of :kind, in: KINDS
  validates_uniqueness_of :name

  after_update { notices.each(&:touch) }

  def self.submitters
    submitter_ids = EntityNoticeRole.submitters.map(&:entity_id)

    where(id: submitter_ids)
  end
end
