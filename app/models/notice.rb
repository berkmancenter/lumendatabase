class Notice < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  RECENT_LIMIT = 7

  HIGHLIGHTS = [ :title, :tag_list, :'categories.name', :submitter_name,
                 :recipient_name, :'works.description', :'works.url',
                 :'infringing_urls.url' ]

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :category_relevant_questions,
    through: :categories, source: :relevant_questions
  has_many :entity_notice_roles, dependent: :destroy, inverse_of: :notice
  has_many :entities, through: :entity_notice_roles
  has_many :file_uploads
  has_many :infringing_urls, through: :works
  has_and_belongs_to_many :relevant_questions

  has_and_belongs_to_many :works

  validates_presence_of :works, :entity_notice_roles

  acts_as_taggable

  accepts_nested_attributes_for :file_uploads,
    reject_if: ->(attributes) { attributes['file'].blank? }

  accepts_nested_attributes_for :entity_notice_roles

  accepts_nested_attributes_for :works

  after_touch { tire.update_index }

  def self.recent
    order('created_at DESC').limit(RECENT_LIMIT)
  end

  def to_indexed_json
    to_json(
      only: [:id, :title],
      methods: [:tag_list, :submitter_name, :recipient_name],
      include: [
        :categories,
        { works: { only: [:description, :url] } },
        { infringing_urls: { only: :url } }
      ]
    )
  end

  def all_relevant_questions
    relevant_questions | category_relevant_questions
  end

  def submitter
    entities_that_have_submitted.first
  end

  def submitter_name
    submitter && submitter.name
  end

  def recipient
    entities_that_have_received.first
  end

  def recipient_name
    recipient && recipient.name
  end

  private

  def entities_that_have_submitted
    entity_notice_roles.submitters.map(&:entity)
  end

  def entities_that_have_received
    entity_notice_roles.recipients.map(&:entity)
  end

end
