# frozen_string_literal: true

require 'validates_automatically'
require 'hierarchical_relationships'

class Entity < ApplicationRecord
  include ValidatesAutomatically
  include HierarchicalRelationships
  include Elasticsearch::Model
  include Searchability

  # == Constants ============================================================
  PER_PAGE = 10
  HIGHLIGHTS = %i[name].freeze
  DO_NOT_INDEX = %w[id name_original]
  KINDS = %w[organization individual].freeze
  ADDITIONAL_DEDUPLICATION_FIELDS =
    %i[address_line_1 city state zip country_code phone email].freeze
  MULTI_MATCH_FIELDS = %w(name^5 kind address_line_1 address_line_2 state
    country_code^2 email url^3 ancestry city zip created_at updated_at)
  REDACTABLE_FIELDS = %w[name address_line_1 address_line_2 city state country_code url].freeze

  # == Relationships ========================================================
  belongs_to :user
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles
  has_and_belongs_to_many :full_notice_only_researchers_users,
                          join_table: :entities_full_notice_only_researchers_users,
                          class_name: 'User'

  # == Attributes ===========================================================
  delegate :publication_delay, to: :user, allow_nil: true

  # == Extensions ===========================================================
  load_elasticsearch_helpers

  # == Validations ==========================================================
  validates :address_line_1, length: { maximum: 255 }
  validates_inclusion_of :kind, in: KINDS

  # == Callbacks ============================================================
  # Force search reindex on related notices
  after_update do
    NoticeUpdateCall.create!(caller_id: self.id, caller_type: 'entity') if self.saved_changes.any?
  end
  after_validation :force_redactions

  # == Class Methods ========================================================
  def self.submitters
    submitter_ids = EntityNoticeRole.submitters.map(&:entity_id)

    where(id: submitter_ids)
  end

  # == Instance Methods =====================================================
  def as_indexed_json(_options)
    out = as_json

    out[:class_name] = 'entity'

    out
  end

  def attributes_for_deduplication
    all_deduplication_attributes = [
      :name, ADDITIONAL_DEDUPLICATION_FIELDS
    ].flatten

    instance_clone = self.dup
    instance_clone.force_redactions

    instance_clone.attributes.select do |key, _value|
      all_deduplication_attributes.include?(key.to_sym)
    end
  end

  def force_redactions
    InstanceRedactor.new.redact(self, REDACTABLE_FIELDS)
  end
end
