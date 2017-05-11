require 'validates_automatically'
require 'hierarchical_relationships'
require 'topic_index_queuer'

class Topic < ActiveRecord::Base
  include ValidatesAutomatically
  include HierarchicalRelationships

  validates :name, length: { maximum: 255 }

  has_many :topic_assignments, dependent: :destroy
  has_many :notices, through: :topic_assignments

  has_many :blog_entry_topic_assignments, dependent: :destroy
  has_many :blog_entries, through: :blog_entry_topic_assignments

  has_and_belongs_to_many :relevant_questions
  has_and_belongs_to_many :topic_managers

  def self.ordered
    order(:name)
  end

  after_update { TopicIndexQueuer.for(self.id) }

  def description_html
    Markdown.render(description.to_s)
  end

end
