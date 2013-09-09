require 'language'
require 'recent_scope'
require 'validates_automatically'

class Notice < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Searchability
  include ValidatesAutomatically

  extend RecentScope

  HIGHLIGHTS = %i(
    title tag_list categories.name sender_name recipient_name
    works.description works.infringing_urls.url works.copyrighted_urls.url
  )

  SEARCHABLE_FIELDS = [
    TermSearch.new(:term, :_all, 'All Fields'),
    TermSearch.new(:title, :title, 'Title'),
    TermSearch.new(:categories, 'categories.name', 'Categories'),
    TermSearch.new(:tags, :tag_list, 'Tags'),
    TermSearch.new(:jurisdictions, :jurisdiction_list, 'Jurisdictions'),
    TermSearch.new(:sender_name, :sender_name, 'Sender Name'),
    TermSearch.new(:recipient_name, :recipient_name, 'Recipient Name'),
    TermSearch.new(:works, 'works.description', 'Works Descriptions'),
    TermSearch.new(:action_taken, :action_taken, 'Action taken'),
  ]

  FILTERABLE_FIELDS = [
    TermFilter.new(:category_facet, 'Category'),
    TermFilter.new(:sender_name_facet, 'Sender'),
    TermFilter.new(:recipient_name_facet, 'Recipient'),
    TermFilter.new(:tag_list_facet, 'Tags'),
    TermFilter.new(:country_code_facet, 'Country'),
    TermFilter.new(:language_facet, 'Language'),
    TermFilter.new(:action_taken_facet, 'Action taken'),
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

  VALID_ACTIONS = %w( Yes No Partial )

  TYPES = {
    'Dmca' => 'DMCA',
    'Trademark' => 'Trademark',
    'Defamation' => 'Defamation',
    'CourtOrder' => 'Court Order',
    'LawEnforcementRequest' => 'Law Enforcement Request',
    'PrivateInformation' => 'Private Information',
    'Other' => 'Other',
  }

  belongs_to :reviewer, class_name: 'User'

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :category_relevant_questions,
    through: :categories, source: :relevant_questions
  has_many :related_blog_entries,
    through: :categories, source: :blog_entries, uniq: true
  has_many :entity_notice_roles, dependent: :destroy, inverse_of: :notice
  has_many :entities, through: :entity_notice_roles
  has_many :file_uploads
  has_many :infringing_urls, through: :works
  has_many :copyrighted_urls, through: :works
  has_and_belongs_to_many :relevant_questions

  has_and_belongs_to_many :works

  validates_inclusion_of :action_taken, in: VALID_ACTIONS
  validates_inclusion_of :language, in: Language.codes, allow_blank: true
  validates_presence_of :works, :entity_notice_roles

  acts_as_taggable_on :tags, :jurisdictions

  accepts_nested_attributes_for :file_uploads,
    reject_if: ->(attributes) { attributes['file'].blank? }

  accepts_nested_attributes_for :entity_notice_roles

  accepts_nested_attributes_for :works

  delegate :country_code, to: :recipient, allow_nil: true
  delegate :name, to: :sender, prefix: true, allow_nil: true
  delegate :name, to: :recipient, prefix: true, allow_nil: true
  delegate :name, to: :submitter, prefix: true, allow_nil: true

  define_elasticsearch_mapping

  def self.type_models
    TYPES.keys.collect do |model_name|
      model_name.constantize
    end
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

  def self.in_categories(categories)
    joins(categorizations: :category).
      where('categories.id' => categories).uniq
  end

  def self.submitted_by(submitters)
    joins(entity_notice_roles: :entity).
      where('entity_notice_roles.name' => :submitter).
      where('entities.id' => submitters)
  end

  def self.add_default_filter(search)
    { rescinded: false, spam: false, hidden: false }.each do |field, value|
      filter = TermFilter.new(field)
      filter.apply_to_search(search, field, value)
    end
  end

  def self.find_visible(notice_id)
    where(spam: false, hidden: false).find(notice_id)
  end

  def active_model_serializer
    if rescinded?
      RescindedNoticeSerializer
    else
      super
    end
  end

  def all_relevant_questions
    relevant_questions | category_relevant_questions
  end

  def limited_related_blog_entries(limit = 5)
    related_blog_entries.limit(limit)
  end

  def submitter
    entities_that_have_submitted.first
  end

  def sender
    entities_that_have_sent.first
  end

  def recipient
    entities_that_have_received.first
  end

  def auto_redact
    RedactsNotices.new.redact(self)
  end

  def mark_for_review
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
    self.class.
      where('id > ? and review_required = ?', id, true).
      order('id asc').
      first
  end

  def tag_list=(tag_list_value = '')
    if tag_list_value.respond_to?(:each)
      tag_list_value = tag_list_value.flatten.map{|tag|tag.downcase}
    else
      tag_list_value = tag_list_value.downcase
    end

    super(tag_list_value)
  end

  def original_documents
    file_uploads.where(kind: 'original')
  end

  def supporting_documents
    file_uploads.where(kind: 'supporting')
  end

  private

  def entities_that_have_submitted
    entity_notice_roles.submitters.map(&:entity)
  end

  def entities_that_have_sent
    entity_notice_roles.senders.map(&:entity)
  end

  def entities_that_have_received
    entity_notice_roles.recipients.map(&:entity)
  end


end
