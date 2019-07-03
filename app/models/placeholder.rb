# frozen_string_literal: true

# Placeholder notices are used when notice providers want to report every
# takedown request of a particular class with, effectively, a form letter (e.g.
# a generic response to law enforcement requests from a given jurisdiction).
class Placeholder < Notice
  DEFAULT_ENTITY_NOTICE_ROLES = %w[submitter].freeze

  def self.model_name
    Notice.model_name
  end

  def self.label
    'Placeholder'
  end

  def to_partial_path
    'notices/placeholder'
  end
end
