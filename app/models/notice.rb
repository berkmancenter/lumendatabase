# frozen_string_literal: true

class Notice < ApplicationRecord
  include Searchability
  include Elasticsearch::Model
  include RepairNestedParams

  extend RecentScope

  # == Constants ============================================================
  HIGHLIGHTS = %i[
    title body tag_list topics.name sender_name recipient_name
    works.description works.infringing_urls.url works.copyrighted_urls.url
  ].freeze

  # Default fields to search with a multimatch query. Weights some of the
  # fields, based purely on intuition from reading logs.
  # Before Elasticsearch 6.x this was an `_all` query, but `_all` is no longer
  # supported. Instead, we define base_search and preferred_search fields which
  # contain all the fields we actually searched via _all, and copy fields to
  # those during indexing (in a mutually exclusive way: fields get copied to
  # one or the other, not both). This lets us do simple weighting.
  # We could simply list all of the fields we would have searched, but that
  # scoring proves to be incredibly slow.
  MULTI_MATCH_FIELDS = %w(base_search preferred_search^2)

  SEARCHABLE_FIELDS = [
    TermSearch.new(:term, MULTI_MATCH_FIELDS, 'All Fields'),
    TermSearch.new(:title, :title, 'Title'),
    TermSearch.new(:topics, 'topics.name', 'Topics'),
    TermSearch.new(:tags, :tag_list, 'Tags'),
    TermSearch.new(:jurisdictions, :jurisdiction_list, 'Jurisdictions'),
    # It's not fully indexed in
    # TermSearch.new(:entities_country_codes, :entities_country_codes, 'Entity Country Code'),
    TermSearch.new(:sender_name, :sender_name, 'Sender Name'),
    TermSearch.new(:principal_name, :principal_name, 'Principal Name'),
    TermSearch.new(:recipient_name, :recipient_name, 'Recipient Name'),
    TermSearch.new(:submitter_name, :submitter_name, 'Submitter Name'),
    TermSearch.new(:submitter_country_code, :submitter_country_code, 'Submitter Country'),
    TermSearch.new(:works, 'works.description', 'Works Descriptions'),
    TermSearch.new(:action_taken, :action_taken, 'Action taken')
  ].freeze

  FILTERABLE_FIELDS = [
    TermFilter.new(:topic_facet, 'Topic'),
    TermFilter.new(:sender_name_facet, 'Sender'),
    TermFilter.new(:principal_name_facet, 'Principal'),
    TermFilter.new(:recipient_name_facet, 'Recipient'),
    TermFilter.new(:submitter_name_facet, 'Submitter'),
    TermFilter.new(:tag_list_facet, 'Tags'),
    TermFilter.new(:country_code_facet, 'Country'),
    TermFilter.new(:language_facet, 'Language'),
    TermFilter.new(:submitter_country_code_facet, 'Submitter Country'),
    UnspecifiedTermFilter.new(:action_taken_facet, 'Action taken'),
    DateRangeFilter.new(:date_received_facet, :date_received, 'Date')
  ].freeze

  ORDERING_OPTIONS = [
    ResultOrdering.new('relevancy desc', [:_score, :desc], 'Most Relevant', true),
    ResultOrdering.new('relevancy asc', [:_score, :asc], 'Least Relevant'),
    ResultOrdering.new('date_received desc', [:date_received, :desc], 'Date Received - newest'),
    ResultOrdering.new('date_received asc', [:date_received, :asc], 'Date Received - oldest'),
    ResultOrdering.new('created_at desc', [:created_at, :desc], 'Reported to Lumen - newest'),
    ResultOrdering.new('created_at asc', [:created_at, :asc], 'Reported to Lumen - oldest')
  ].freeze

  REDACTABLE_FIELDS = %i[body].freeze
  PER_PAGE = 10

  UNDER_REVIEW_VALUE = 'Under review'.freeze
  RANGE_SEPARATOR = '..'.freeze

  # Base entity notice roles allow us to define additional roles on subclasses
  # without having to keep track of what they are on notice. As long as
  # subclasses define DEFAULT_ENTITY_NOTICE_ROLES =
  # BASE_ENTITY_NOTICE_ROLES | local_roles, the OR will preserve all elements
  # of both.
  BASE_ENTITY_NOTICE_ROLES = %w[submitter].freeze
  DEFAULT_ENTITY_NOTICE_ROLES = (BASE_ENTITY_NOTICE_ROLES |
                                 %w[recipient sender]).freeze

  VALID_ACTIONS = %w[Yes No Partial Unspecified].freeze

  # == Relationships ========================================================
  belongs_to :reviewer, class_name: 'User'

  has_many :topic_assignments, dependent: :destroy
  has_many :topics, through: :topic_assignments
  has_many :topic_relevant_questions, through: :topics, source: :relevant_questions

  has_many :entity_notice_roles, dependent: :destroy, inverse_of: :notice
  has_many :entities, through: :entity_notice_roles, index_errors: true

  has_many :token_urls, dependent: :destroy
  has_many :archived_token_urls, dependent: :destroy
  has_and_belongs_to_many :relevant_questions
  has_one :documents_update_notification_notice
  has_many :file_uploads

  # == Attributes ===========================================================
  delegate :country_code, to: :recipient, allow_nil: true

  %i[sender principal recipient submitter attorney].each do |entity|
    delegate :name, :country_code, to: entity, prefix: true, allow_nil: true
  end

  attr_accessor :works

  # == Extensions ===========================================================
  accepts_nested_attributes_for :file_uploads, allow_destroy: true,
    reject_if: ->(attributes) { [attributes['file'], attributes[:pdf_request_fulfilled]].all?(&:blank?) }

  accepts_nested_attributes_for :entity_notice_roles, allow_destroy: true

  load_elasticsearch_helpers

  # == Validations ==========================================================
  validates_inclusion_of :action_taken, in: VALID_ACTIONS, allow_blank: true
  validates_inclusion_of :language, in: Language.codes, allow_blank: true
  validates_presence_of :works, :entity_notice_roles
  validates :date_sent, date: { after: Proc.new { Date.new(1998,10,28) }, before: Proc.new { Time.now + 1.day }, allow_blank: true }
  validates :date_received, date: { after: Proc.new { Date.new(1998,10,28) }, before: Proc.new { Time.now + 1.day }, allow_blank: true }
  validates_associated :works

  # == Callbacks ============================================================
  after_initialize :set_works
  before_save :set_topics
  before_save :set_works_json
  after_create :set_published!, if: :submitter
  # This may fail in the dev environment if you don't have ES up and running,
  # but is works in other envs.
  after_destroy do
    __elasticsearch__.delete_document ignore: 404
  end
  after_update :clear_proxy_cache

  # == Scopes ===============================================================
  scope :top_notices_token_urls, -> { joins(:archived_token_urls).select('notices.*, COUNT(archived_token_urls.id) AS counted_archived_token_urls').group('notices.id') }
  scope :with_attachments, -> { includes(:file_uploads).where.not(file_uploads: { id: nil }) }

  # == Aliases ==============================================================
  alias_attribute :tags, :tag_list
  alias_attribute :jurisdictions, :jurisdiction_list
  alias_attribute :regulations, :regulation_list

  # == Class Methods ========================================================
  def self.label
    name.titleize
  end

  def self.type_models
    (Lumen::TYPES - ['Counternotice']).map(&:constantize).freeze
  end

  def self.display_models
    (Lumen::TYPES - ['Placeholder']).map(&:constantize).freeze
  end

  def self.available_for_review
    where(
      review_required: true,
      reviewer_id: nil,
      hidden: false,
      spam: false
    )
  end

  def self.in_review(user)
    where(review_required: true, reviewer_id: user).order(:created_at)
  end

  def self.in_topics(topics)
    joins(topic_assignments: :topic)
      .where('topics.id' => topics)
      .distinct
  end

  def self.submitted_by(submitters)
    joins(entity_notice_roles: :entity)
      .where('entity_notice_roles.name' => :submitter)
      .where('entities.id' => submitters)
  end

  def self.find_visible(notice_id)
    self.visible.find(notice_id)
  end

  def self.visible
    where(visible_qualifiers)
  end

  def self.visible_qualifiers
    { spam: false, hidden: false, published: true, rescinded: false }
  end

  def self.find_unpublished(notice_id)
    self.where(spam: false, hidden: false, published: false).find(notice_id)
    true
  rescue
    false
  end

  def self.get_approximate_count
    ActiveRecord::Base.connection.execute("SELECT reltuples FROM pg_class WHERE relname = 'notices'").getvalue(0, 0).to_i
  end

  # == Instance Methods =====================================================

  # Using reset_type because type is ALWAYS protected (deep in the Rails code).
  # attr_protected :id, :type, :reset_type
  # attr_protected :id, :type, as: :admin
  def reset_type
    type
  end

  def reset_type=(value)
    unless value.in?(Lumen::TYPES)
      fail ActiveModel::MissingAttributeError.new("Cannot reset Notice type to: #{value}")
    end
    self[:type] = value
  end

  def reset_type_enum
    Lumen::TYPES
  end

  def language_enum
    Language.all.inject( {} ) { |memo, l| memo[l.label] = l.code; memo }
  end

  def model_serializer
    if rescinded?
      RescindedNoticeSerializer
    else
      "#{self.class.name}Serializer".safe_constantize
    end
  end

  def other_entity_notice_roles
    other_roles = EntityNoticeRole.all_roles_names - Notice::DEFAULT_ENTITY_NOTICE_ROLES
    entity_notice_roles.find_all do |entity_notice_role|
      other_roles.include?(entity_notice_role.name)
    end
  end

  def submitter
    @submitter ||= submitters.first
  end

  def sender
    @sender ||= senders.first
  end

  def principal
    @principal ||= principals.first
  end

  def recipient
    @recipient ||= recipients.first
  end

  def attorney
    @attorney ||= attorneys.first
  end

  def auto_redact
    InstanceRedactor.new.redact(self)
  end

  def mark_for_review
    # We can't do this before notice creation, because the assessment may
    # depend on values of related entities, and the relationships aren't
    # available to traverse before persistence.
    unless persisted?
      Rails.logger.warn('Attempted to mark a notice for review before creation')
      return
    end

    update_column(:review_required, RiskAssessment.new(self).high_risk?)
  end

  def redacted(field)
    if review_required?
      UNDER_REVIEW_VALUE
    else
      send(field)
    end
  end

  def next_requiring_review
    self.class
      .where('id > ? and review_required = ?', id, true)
      .order('id asc')
      .first
  end

  def jurisdiction_list=(value = '')
    super(split_and_strip(value))
  end

  def regulation_list=(value = '')
    super(split_and_strip(value))
  end

  def tag_list=(value = '')
    unless value.nil?
      value = if value.respond_to?(:each)
                value.flatten.map(&:downcase)
              else
                value.downcase
              end
    end

    super(split_and_strip(value))
  end

  def jurisdiction_list
    return [] if self[:jurisdiction_list].nil?

    self[:jurisdiction_list]
  end

  def regulation_list
    return [] if self[:regulation_list].nil?

    self[:regulation_list]
  end

  def tag_list
    return [] if self[:tag_list].nil?

    self[:tag_list]
  end

  def original_documents
    file_uploads.where(kind: 'original')
  end

  def supporting_documents
    file_uploads.where(kind: 'supporting')
  end

  def on_behalf_of_principal?
    return unless sender_name.present?
    principal_name.present? && principal_name != sender_name
  end

  def publication_delay
    submitter && submitter.publication_delay ? submitter.publication_delay : 0
  end

  def time_to_publish
    created_at + publication_delay.seconds
  end

  def should_be_published?
    time_to_publish <= Time.now
  end

  def set_published!
    self.published = should_be_published?
    save
  end

  def notice_topic_map
    topic = Lumen::TYPES_TO_TOPICS.key?(self.type) ? Lumen::TYPES_TO_TOPICS[self.type] : Lumen::OTHER_TOPIC
    Topic.find_or_create_by(name: topic)
  end

  def hide_identities?
    false
  end

  def set_topics
    topic = notice_topic_map
    topics << topic unless topics.include?(topic)
  end

  def works_json=(value)
    value = JSON.parse(value) if value.is_a?(String)
    value = recursive_compact(value)
    @works = value.map { |work_json| Work.new(work_json) } if value.present?
    super(value)
  end

  def set_works
    # When it's not set by works_attributes=
    @works = [] if @works.nil?

    # Map the existing works in jsonb to the Work model
    @works = self.works_json.map { |work_json| Work.new(work_json) } if self.works_json.present?
  end

  def set_works_json
    @works.each do |work|
      work.force_redactions
      work.fix_concatenated_urls
    end

    self.works_json = @works.map { |w| prep_work_json(w) }
  end

  def works_attributes=(works_attrs)
    if works_attrs.is_a?(Hash)
      works_attrs = repair_nested_params({ k: works_attrs })[:k]
    end

    @works = works_attrs.map { |work| Work.new(work) }
  end

  def prep_work_json(work)
    json = {
      kind: work.kind,
      description: work.description,
      copyrighted_urls: work.copyrighted_urls.map { |u| prep_url_json(u) },
      infringing_urls: work.infringing_urls.map { |u| prep_url_json(u) }
    }

    if work.description_original && work.description_original != work.description
      json[:description_original] = work.description_original
    end

    json
  end

  def prep_url_json(url_instance)
    json = { url: url_instance.url }

    if url_instance.url_original && url_instance.url_original != url_instance.url
      json[:url_original] = url_instance.url_original
    end

    json
  end

  def restricted_to_researchers?
    submitter&.full_notice_only_researchers
  end

  def token_urls_count
    archived_token_urls.count
  end

  private

  def submitters
    select_roles 'submitter'
  end

  def senders
    select_roles 'sender'
  end

  def principals
    select_roles 'principal'
  end

  def recipients
    select_roles 'recipient'
  end

  def attorneys
    select_roles 'attorney'
  end

  def select_roles(role_name)
    entity_notice_roles.select{ |entity_notice_role| entity_notice_role.name == role_name }.map(&:entity)
  end

  def entities_country_codes
    entities.map(&:country_code).uniq
  end

  def recursive_compact(data)
    case data
    when Array
      data.delete_if { |value| res = recursive_compact(value); res.blank? }
    when Hash
      data.delete_if { |_, value| res = recursive_compact(value); res.blank? }
    end
    data.blank? ? nil : data
  end

  def split_and_strip(value)
    return value.split(',').map(&:strip) if value.is_a? String

    value
  end

  # the "as" attribute is not implemented in elasticsearch-rails
  # according to https://github.com/elastic/elasticsearch-rails/issues/21
  # it's the best workaround
  def as_indexed_json(_options)
    out = as_json(except: [:jurisdiction_list, :regulation_list, :tag_list, :works_json])

    attributes_to_skip = %w[review_required reviewer_id url_count
                            webform notes views_overall views_by_notice_viewer
                            works_json]
    out.except!(*attributes_to_skip)

    out['class_name'] = self.class.name
    out['sender_name_facet'] = sender_name
    out['sender_name'] = sender_name
    out['principal_name_facet'] = principal_name
    out['principal_name'] = principal_name
    out['submitter_name_facet'] = submitter_name
    out['submitter_name'] = submitter_name
    out['submitter_country_code_facet'] = submitter_country_code
    out['submitter_country_code'] = submitter_country_code
    out['tag_list_facet'] = tags
    out['tag_list'] = tags
    out['date_received_facet'] = date_received
    out['jurisdiction_list_facet'] = jurisdictions
    out['jurisdiction_list'] = jurisdictions
    out['recipient_name_facet'] = recipient_name
    out['recipient_name'] = recipient_name
    out['country_code_facet'] = country_code
    out['language_facet'] = language
    out['action_taken_facet'] = action_taken
    out['topic_facet'] = topics.map(&:name)
    out['topics'] = topics.map do |topic|
      { id: topic[:id], name: topic[:name] }
    end
    out['works'] = works.map do |work|
      {
        description: work.description,
        infringing_urls: work.infringing_urls.map { |iurl| { url: iurl.url } },
        copyrighted_urls: work.copyrighted_urls.map { |curl| { url: curl.url } }
      }
    end
    out['entities_country_codes'] = entities_country_codes

    out
  end

  def clear_proxy_cache
    ProxyCache.clear_notice(id)
  end
end
