require 'language'
require 'recent_scope'
require 'validates_automatically'

class Notice < ActiveRecord::Base
  include Tire::Model::Search
  include Searchability

  extend RecentScope

  HIGHLIGHTS = %i(
    title tag_list topics.name sender_name recipient_name
    works.description works.infringing_urls.url works.copyrighted_urls.url
  )

  SEARCHABLE_FIELDS = [
    TermSearch.new(:term, :_all, 'All Fields'),
    TermSearch.new(:title, :title, 'Title'),
    TermSearch.new(:topics, 'topics.name', 'Topics'),
    TermSearch.new(:tags, :tag_list, 'Tags'),
    TermSearch.new(:jurisdictions, :jurisdiction_list, 'Jurisdictions'),
    TermSearch.new(:sender_name, :sender_name, 'Sender Name'),
    TermSearch.new(:principal_name, :principal_name, 'Principal Name'),
    TermSearch.new(:recipient_name, :recipient_name, 'Recipient Name'),
    TermSearch.new(:submitter_name, :submitter_name, 'Submitter Name'),
    TermSearch.new(:submitter_country_code, :submitter_country_code, 'Submitter Country'),
    TermSearch.new(:works, 'works.description', 'Works Descriptions'),
    TermSearch.new(:action_taken, :action_taken, 'Action taken'),
  ]

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
  ]

  SORTINGS = [
    Sorting.new('relevancy desc', [:_score, :desc], 'Most Relevant'),
    Sorting.new('relevancy asc', [:_score, :asc], 'Least Relevant'),
    Sorting.new('date_received desc', [:date_received, :desc],  'Newest'),
    Sorting.new('date_received asc', [:date_received, :asc],  'Oldest'),
  ]

  REDACTABLE_FIELDS = %i( body )
  PER_PAGE = 10

  UNDER_REVIEW_VALUE = 'Under review'
  RANGE_SEPARATOR = '..'

  DEFAULT_ENTITY_NOTICE_ROLES = %w|recipient sender|

  VALID_ACTIONS = %w( Yes No Partial Unspecified )

  OTHER_TOPIC = "Uncategorized"

  TYPES_TO_TOPICS = {
    'DMCA'                  => "Copyright",
    'Counternotice'         => "Copyright",
    'Trademark'             => "Trademark",
    'Defamation'            => "Defamation",
    'CourtOrder'            => "Court Orders",
    'LawEnforcementRequest' => "Law Enforcement Requests",
    'PrivateInformation'    => "Right of Publicity",
    'DataProtection'        => "EU - Right to Be Forgotten",
    'GovernmentRequest'     => "Government Requests",
    'Other'                 => OTHER_TOPIC
  }

  TYPES = TYPES_TO_TOPICS.keys
  TOPICS = TYPES_TO_TOPICS.values

  belongs_to :reviewer, class_name: 'User'

  has_many :topic_assignments, dependent: :destroy
  has_many :topics, through: :topic_assignments
  has_many :topic_relevant_questions, through: :topics, source: :relevant_questions
  has_many :related_blog_entries, -> { distinct }, through: :topics, source: :blog_entries
  has_many :entity_notice_roles, dependent: :destroy, inverse_of: :notice
  has_many :entities, through: :entity_notice_roles
  has_many :file_uploads
  has_many :infringing_urls, through: :works
  has_many :copyrighted_urls, through: :works
  has_and_belongs_to_many :relevant_questions

  has_and_belongs_to_many :works

  validates_inclusion_of :action_taken, in: VALID_ACTIONS, allow_blank: true
  validates_inclusion_of :language, in: Language.codes, allow_blank: true
  validates_presence_of :works, :entity_notice_roles
  validates :date_sent, date: { after: Proc.new { Date.new(1998,10,28) }, before: Proc.new { Time.now + 1.day }, allow_blank: true }
  validates :date_received, date: { after: Proc.new { Date.new(1998,10,28) }, before: Proc.new { Time.now + 1.day }, allow_blank: true }

  # Using reset_type because type is ALWAYS protected (deep in the Rails code).
  # attr_protected :id, :type, :reset_type
  # attr_protected :id, :type, as: :admin

  def reset_type
    type
  end

  def reset_type=(value)
    unless value.in?(TYPES)
      fail ActiveModel::MissingAttributeError.new("Cannot reset Notice type to: #{value}")
    end
    self[:type] = value
  end

  def reset_type_enum
    TYPES
  end

  def language_enum
    Language.all.inject( {} ) { |memo, l| memo[l.label] = l.code; memo }
  end

  acts_as_taggable_on :tags, :jurisdictions

  accepts_nested_attributes_for :file_uploads,
    reject_if: ->(attributes) { [attributes['file'], attributes[:pdf_request_fulfilled]].all?(&:blank?) }

  accepts_nested_attributes_for :entity_notice_roles, :allow_destroy => true

  accepts_nested_attributes_for :works, :allow_destroy => true

  delegate :country_code, to: :recipient, allow_nil: true

  %i( sender principal recipient submitter attorney ).each do |entity|
    delegate :name, :country_code, to: entity, prefix: true, allow_nil: true
  end

  after_create :set_published!, if: :submitter
  after_destroy :remove_from_index

  define_elasticsearch_mapping

  def self.label
    name.titleize
  end

  def self.type_models
    ( TYPES - ['Counternotice'] ).map(&:constantize)
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
    joins(topic_assignments: :topic).
      where('topics.id' => topics).uniq
  end

  def self.submitted_by(submitters)
    joins(entity_notice_roles: :entity).
      where('entity_notice_roles.name' => :submitter).
      where('entities.id' => submitters)
  end

  def self.add_default_filter(search)
    { rescinded: false, spam: false, hidden: false, published: true }.each do |field, value|
      filter = TermFilter.new(field)
      filter.apply_to_search(search, field, value)
    end
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
    begin 
      self.where(spam: false, hidden: false, published: false).find(notice_id)
      return true
    rescue
      return false
    end    
  end

  def active_model_serializer
    if rescinded?
      RescindedNoticeSerializer
    else
      super
    end
  end

  def all_relevant_questions(limit = 15)
    (relevant_questions | topic_relevant_questions).sample(limit)
  end

  def related_blog_entries(limit = 5)
    super.published.limit(limit)
  end

  def other_entity_notice_roles
    other_roles = self.class::DEFAULT_ENTITY_NOTICE_ROLES - Notice::DEFAULT_ENTITY_NOTICE_ROLES
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
    RedactsNotices.new.redact(self)
  end

  def mark_for_review
    update_column(:review_required, RiskAssessment.new(self).high_risk?)
  end

  def copy_id_to_submission_id
    update_column(:submission_id, id)
  end

  def redacted(field)
    if review_required?
      UNDER_REVIEW_VALUE
    else
      send(field)
    end
  end

  def next_requiring_review
    self.class.
      where('id > ? and review_required = ?', id, true).
      order('id asc').
      first
  end

  def tag_list
    @tag_list ||= super
  end

  def jurisdiction_list
    @jurisdiction_list ||= super
  end

  def tag_list=(tag_list_value = '')
    unless tag_list_value.nil?
      if tag_list_value.respond_to?(:each)
        tag_list_value = tag_list_value.flatten.map{|tag|tag.downcase}
      else
        tag_list_value = tag_list_value.downcase
      end
    end

    super(tag_list_value)
  end

  def original_documents
    file_uploads.where(kind: 'original')
  end

  def supporting_documents
    file_uploads.where(kind: 'supporting')
  end

  def on_behalf_of_principal?
    if sender_name.present?
      principal_name.present? && principal_name != sender_name
    end
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
    topic = TYPES_TO_TOPICS.key?(self.type) ? TYPES_TO_TOPICS[self.type] : OTHER_TOPIC
    return Topic.find_or_create_by(name: topic)
  end

  def hide_identities?
    false
  end

  before_save do
    notice_type = self.type
    topic = self.notice_topic_map

    unless self.topics.include?(topic)
      self.topics << topic
    end  
  end

  private

  def submitters
    entity_notice_roles.submitters.map(&:entity)
  end

  def senders
    entity_notice_roles.senders.map(&:entity)
  end

  def principals
    entity_notice_roles.principals.map(&:entity)
  end

  def recipients
    entity_notice_roles.recipients.map(&:entity)
  end

  def attorneys
    entity_notice_roles.attorneys.map(&:entity)
  end

  def remove_from_index
    self.index.remove self
  end
end
