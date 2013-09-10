require 'recent_scope'
require 'validates_automatically'

class BlogEntry < ActiveRecord::Base
  extend RecentScope
  include ValidatesAutomatically

  def self.valid_images
    imagery_directory = Rails.root.join('app/assets/images/blog/imagery')

    Dir["#{imagery_directory}/*.jpg"].map do |file|
      File.basename(file, '.jpg')
    end
  end

  # TODO: is the simple :author attribute enough? Does the Association
  # really give us anything?
  belongs_to :user

  has_many :blog_entry_categorizations, dependent: :destroy
  has_many :categories, through: :blog_entry_categorizations

  validates_inclusion_of :image, in: valid_images, allow_nil: true

  def content_html
    Markdown.render(content.to_s)
  end

  # https://github.com/sferik/rails_admin/wiki/Enumeration
  def image_enum
    self.class.valid_images
  end
end
