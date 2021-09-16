require 'validates_automatically'

class MediaMention < ApplicationRecord
  include ValidatesAutomatically
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  PER_PAGE = 10

  MULTI_MATCH_FIELDS = %w(base_search)

  SEARCHABLE_FIELDS = [
    TermSearch.new(:term, MULTI_MATCH_FIELDS, 'All Fields')
  ].freeze

  now = Time.now.beginning_of_day
  DATE_FACET_RANGES = [
    { from: now - 1.year, to: now },
    { from: now - 5.years, to: now  },
    { from: now - 10.years, to: now },
    { from: now - 20.years, to: now }
  ]

  FILTERABLE_FIELDS = [
    TermFilter.new(:source_facet, 'Source'),
    TermFilter.new(:document_type_facet, 'Document Type'),
    DateRangeFilter.new(:date_facet, :date, 'Date Published', DATE_FACET_RANGES)
  ].freeze

  ORDERING_OPTIONS = [
    ResultOrdering.new('relevancy desc', [:_score, :desc], 'Most Relevant'),
    ResultOrdering.new('relevancy asc', [:_score, :asc], 'Least Relevant'),
    ResultOrdering.new('date desc', [:date, :desc], 'Date Published - newest', true),
    ResultOrdering.new('date asc', [:date, :asc], 'Date Published - oldest')
  ].freeze

  HIGHLIGHTS = [].freeze

  settings do
    mappings dynamic: false do
      # fields
      indexes :base_search, type: 'text'
      indexes :title, copy_to: 'base_search'
      indexes :description, copy_to: 'base_search'
      indexes :source, copy_to: %w[base_search source_facet]
      indexes :document_type, copy_to: %w[base_search document_type_facet]
      indexes :date, type: 'date', copy_to: %w[base_search date_facet]
      indexes :published, type: 'boolean'
      indexes :author, copy_to: 'base_search'

      # facets
      indexes :source_facet, type: 'keyword'
      indexes :document_type_facet, type: 'keyword'
      indexes :date_facet, type: 'date'
    end
  end

  def self.visible_qualifiers
    { published: true }
  end
end
