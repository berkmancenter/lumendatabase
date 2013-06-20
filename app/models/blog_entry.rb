require 'recent_scope'
require 'validates_automatically'

class BlogEntry < ActiveRecord::Base
  extend RecentScope
  include ValidatesAutomatically

  # TODO: is the simple :author attribute enough? Does the Association
  # really give us anything?
  belongs_to :user

  has_many :blog_entry_categorizations, dependent: :destroy
  has_many :categories, through: :blog_entry_categorizations

  def content_html
    Markdown.render(content.to_s)
  end
end
