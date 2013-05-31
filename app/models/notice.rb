class Notice < ActiveRecord::Base

  has_and_belongs_to_many :categories
  has_many :category_relevant_questions,
    through: :categories, source: :relevant_questions
  has_many :entity_notice_roles, dependent: :destroy
  has_many :entities, through: :entity_notice_roles
  has_many :file_uploads
  has_many :infringing_urls, through: :works
  has_and_belongs_to_many :relevant_questions

  has_and_belongs_to_many :works

  acts_as_taggable

  validates_presence_of :title

  def self.recent
    where('date_received > ?', 1.week.ago).order('date_received DESC')
  end

  def notice_file_content
    first_notice.read
  end

  def all_relevant_questions
    relevant_questions | category_relevant_questions
  end

  private

  def first_notice
    file_uploads.notices.first || NullFileUpload.new
  end
end
