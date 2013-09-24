require 'recent_scope'
require 'validates_automatically'

class BlogEntry < ActiveRecord::Base
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
    where("url IS NULL")
  end

  def self.we_are_reading
    where("url IS NOT NULL")
  end

  def self.published
    where('published_at <= ?', Time.now).order('published_at DESC')
  end

  def content_html
    Markdown.render(content.to_s)
  end

  def abstract_html
    Markdown.render(abstract.to_s)
  end

  # https://github.com/sferik/rails_admin/wiki/Enumeration
  def image_enum
    self.class.valid_images
  end

end
