require 'recent_scope'
require 'validates_automatically'

class BlogEntry < ApplicationRecord
  extend RecentScope
  include ValidatesAutomatically

  # TODO: is the simple :author attribute enough? Does the Association
  # really give us anything?
  belongs_to :user

  has_many :blog_entry_topic_assignments, dependent: :destroy
  has_many :topics, through: :blog_entry_topic_assignments

  # must be defined before its use in validates_inclusion_of
  def self.valid_images
    imagery_directory = Rails.root.join('app/assets/images/blog/imagery')

    Dir["#{imagery_directory}/*.jpg"].map do |file|
      File.basename(file, '.jpg')
    end
  end

  validates_inclusion_of :image, in: valid_images, allow_nil: true

  def self.with_content
    where("url = '' or url IS NULL")
  end

  def self.we_are_reading
    where("url != '' and url IS NOT NULL")
  end

  def self.published
    where('published_at <= ?', Time.now)
      .where(archive: false)
      .order('published_at DESC')
  end

  def self.archived
    where('published_at <= ?', Time.now)
      .where(archive: true)
      .order('published_at DESC')
  end

  def self.recent_posts
    where('published_at <= ?', Time.now)
      .where(archive: false)
      .where("url = '' or url IS NULL")
      .order('published_at DESC')
      .first(5)
  end

  def content_html
    MarkdownParser.render(content.to_s)
  end

  def abstract_html
    MarkdownParser.render(abstract.to_s)
  end

  # https://github.com/sferik/rails_admin/wiki/Enumeration
  def image_enum
    self.class.valid_images
  end
end
