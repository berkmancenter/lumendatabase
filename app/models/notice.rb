require 'language'
require 'recent_scope'
require 'validates_automatically'

class Notice < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include ValidatesAutomatically

  extend RecentScope

  HIGHLIGHTS = %i(
    title tag_list categories.name sender_name recipient_name
    works.description works.url infringing_urls.url
  )

  REDACTABLE_FIELDS = %i( legal_other body )
  PER_PAGE = 10

  UNDER_REVIEW_VALUE = 'Under review'
  RANGE_SEPARATOR = '..'

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
  has_and_belongs_to_many :relevant_questions

  has_and_belongs_to_many :works

  validates_inclusion_of :language, in: Language.codes, allow_blank: true
  validates_presence_of :works, :entity_notice_roles

  acts_as_taggable

  accepts_nested_attributes_for :file_uploads,
    reject_if: ->(attributes) { attributes['file'].blank? }

  accepts_nested_attributes_for :entity_notice_roles

  accepts_nested_attributes_for :works

  after_touch { tire.update_index }

  delegate :country_code, to: :recipient, allow_nil: true
  delegate :name, to: :sender, prefix: true, allow_nil: true
  delegate :name, to: :recipient, prefix: true, allow_nil: true

  mapping do
    indexes :id, index: 'not_analyzed', include_in_all: false
    indexes :title
    indexes :date_received, type: 'date', include_in_all: false
    indexes :tag_list, as: 'tag_list'
    indexes :sender_name, as: 'sender_name'
    indexes :sender_name_facet,
      analyzer: 'keyword', as: 'sender_name',
      include_in_all: false
    indexes :tag_list_facet,
      analyzer: 'keyword', as: 'tag_list',
      include_in_all: false
    indexes :recipient_name, as: 'recipient_name'
    indexes :recipient_name_facet,
      analyzer: 'keyword', as: 'recipient_name', include_in_all: false
    indexes :country_code_facet,
      analyzer: 'keyword', as: 'country_code', include_in_all: false
    indexes :language_facet,
      analyzer: 'keyword', as: 'language', include_in_all: false
    indexes :categories, type: 'object', as: 'categories'
    indexes :category_facet,
      analyzer: 'keyword', as: ->(notice) { notice.categories.map(&:name) },
      include_in_all: false
    indexes :works,
      type: 'object',
      as: -> (notice){
        notice.works.as_json({
          only: [:description, :url],
          include: { infringing_urls: { only: [:url] } }
        })
      }
  end

  def self.available_for_review
    where(review_required: true, reviewer_id: nil)
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
