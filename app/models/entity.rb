require 'validates_automatically'

class Entity < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include ValidatesAutomatically

  PER_PAGE = 10
  HIGHLIGHTS = %i(name)

  belongs_to :user
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
  ADDITIONAL_DEDUPLICATION_FIELDS =
    %i(address_line_1 city state zip country_code phone email)

  validates_inclusion_of :kind, in: KINDS
  validates_uniqueness_of :name,
    scope: ADDITIONAL_DEDUPLICATION_FIELDS

  after_update { notices.each(&:touch) }

  def attributes_for_deduplication
    all_deduplication_attributes = [
      :name, ADDITIONAL_DEDUPLICATION_FIELDS
    ].flatten

    attributes.select do |key, value|
      all_deduplication_attributes.include?(key.to_sym)
    end
  end

  def self.submitters
    submitter_ids = EntityNoticeRole.submitters.map(&:entity_id)

    where(id: submitter_ids)
  end
end
