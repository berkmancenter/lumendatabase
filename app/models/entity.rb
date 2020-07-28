# frozen_string_literal: true

require 'validates_automatically'
require 'hierarchical_relationships'
require 'default_name_original'

class Entity < ApplicationRecord
  include ValidatesAutomatically
  include HierarchicalRelationships
  include DefaultNameOriginal
  include Elasticsearch::Model

  # == Constants ============================================================
  PER_PAGE = 10
  HIGHLIGHTS = %i[name].freeze
  DO_NOT_INDEX = %w[id name_original]
  KINDS = %w[organization individual].freeze
  ADDITIONAL_DEDUPLICATION_FIELDS =
    %i[address_line_1 city state zip country_code phone email].freeze
  MULTI_MATCH_FIELDS = %w(name^5 kind address_line_1 address_line_2 state
    country_code^2 email url^3 ancestry city zip created_at updated_at)

  # == Relationships ========================================================
  belongs_to :user
  has_many :entity_notice_roles, dependent: :destroy
  has_many :notices, through: :entity_notice_roles

  # == Attributes ===========================================================
  delegate :publication_delay, to: :user, allow_nil: true

  # == Extensions ===========================================================
  index_name [Rails.application.engine_name,
              Rails.env,
              name.demodulize.downcase,
              ENV['ES_INDEX_SUFFIX']].compact.join('_')

  mappings dynamic: false do
    Entity.columns
          .map(&:name)
          .reject { |name| DO_NOT_INDEX.include? name }
          .each do |column_name|
      indexes column_name
    end

    indexes :parent_id
  end

  # == Validations ==========================================================
  validates :address_line_1, length: { maximum: 255 }
  validates_inclusion_of :kind, in: KINDS
  validates_uniqueness_of :name,
                          scope: ADDITIONAL_DEDUPLICATION_FIELDS

  # == Callbacks ============================================================
  # We do this because it will trigger associated notices to be reindexed
  # at the next reindex run, allowing their submitter_name and similar fields
  # to change in Elasticsearch. This is important because if we redact these
  # fields on Entity, we want those redactions to be reflected in the UI.
  # Using ActiveRecord callbacks to alter associated models is a bad plan (see
  # https://youtu.be/cgneN2ISuGY) because it couples them tightly together, but
  # they were already coupled tightly together because Elasticsearch indexes
  # fields on Notice which are derived from Entity, so we aren't making things
  # much worse, and this is far and away the simplest way to force reindexing
  # of Notice.
  # update_all is dramatically more performant than e.g. update -- it skips
  # all validations and constructs a single SQL statement to update all the
  # notices.
  after_save { notices.update_all(updated_at: Time.now) }

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

    attributes.select do |key, _value|
      all_deduplication_attributes.include?(key.to_sym)
    end
  end
end
