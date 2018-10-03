require 'validates_automatically'
require 'hierarchical_relationships'
require 'entity_index_queuer'
require 'default_name_original'

class Entity < ActiveRecord::Base
  include ValidatesAutomatically
  include HierarchicalRelationships
  include DefaultNameOriginal
  include Elasticsearch::Model

  PER_PAGE = 10
  HIGHLIGHTS = %i[name].freeze

  validates :address_line_1, length: { maximum: 255 }

  belongs_to :user
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles

  delegate :publication_delay, to: :user, allow_nil: true

  mappings do
    Entity.columns
          .map(&:name)
          .reject { |name| name == 'id' }
          .each do |column_name|
      indexes column_name
    end

    indexes :parent_id
  end

  index_name [Rails.application.engine_name,
              Rails.env,
              self.name.demodulize.downcase].join('_')

  def as_indexed_json(_options)
    out = as_json

    out[:class_name] = 'entity'

    out
  end

  KINDS = %w[organization individual].freeze
  ADDITIONAL_DEDUPLICATION_FIELDS =
    %i[address_line_1 city state zip country_code phone email].freeze

  validates_inclusion_of :kind, in: KINDS
  validates_uniqueness_of :name,
                          scope: ADDITIONAL_DEDUPLICATION_FIELDS

  after_update { EntityIndexQueuer.for(id) }

  def attributes_for_deduplication
    all_deduplication_attributes = [
      :name, ADDITIONAL_DEDUPLICATION_FIELDS
    ].flatten

    attributes.select do |key, _value|
      all_deduplication_attributes.include?(key.to_sym)
    end
  end

  def self.submitters
    submitter_ids = EntityNoticeRole.submitters.map(&:entity_id)

    where(id: submitter_ids)
  end
end
