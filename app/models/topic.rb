require 'validates_automatically'
require 'hierarchical_relationships'

class Topic < ApplicationRecord
  include ValidatesAutomatically
  include HierarchicalRelationships

  validates :name, length: { maximum: 255 }

  has_many :topic_assignments, dependent: :destroy
  has_many :notices, through: :topic_assignments

  has_and_belongs_to_many :relevant_questions
  has_and_belongs_to_many :topic_managers

  def self.ordered
    order(:name)
  end

  # Force search reindex on related notices
  after_update { NoticeUpdateCall.create!(caller_id: self.id, caller_type: 'topic') if self.saved_changes.any? }

  def description_html
    MarkdownParser.render(description.to_s)
  end

end
