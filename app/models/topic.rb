require 'validates_automatically'

class Topic < ActiveRecord::Base
  include ValidatesAutomatically

  has_many :topic_assignments, dependent: :destroy
  has_many :notices, through: :topic_assignments

  has_many :blog_entry_topic_assignments, dependent: :destroy
  has_many :blog_entries, through: :blog_entry_topic_assignments

  has_and_belongs_to_many :relevant_questions
  has_and_belongs_to_many :topic_managers

  has_ancestry

  def self.ordered
    order(:name)
  end

  after_update { notices.each(&:touch) }

  def description_html
    Markdown.render(description.to_s)
  end

end
