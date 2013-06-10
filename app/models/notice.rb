class Notice < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  RECENT_LIMIT = 7

  HIGHLIGHTS = [ :title, :tags, :'categories.name', :submitter_name,
                 :recipient_name, :'infringing_urls.url' ]

  has_and_belongs_to_many :categories
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

  def self.recent
    order('created_at DESC').limit(RECENT_LIMIT)
  end

  def to_indexed_json
    {
      id: id,
      title: title,
      categories: categories.as_json(only: [:id, :name]),
      tags: tag_list,
      submitter_name: submitter_name,
      recipient_name: recipient_name,
      infringing_urls: infringing_urls.as_json(only: :url)
    }.to_json
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
