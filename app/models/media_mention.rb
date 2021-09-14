require 'validates_automatically'

class MediaMention < ApplicationRecord
  include ValidatesAutomatically
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  PER_PAGE = 10

  MULTI_MATCH_FIELDS = %w(title description document_type source)

  SEARCHABLE_FIELDS = [
    TermSearch.new(:term, MULTI_MATCH_FIELDS, 'All Fields')
  ].freeze

  FILTERABLE_FIELDS = [].freeze

  ORDERING_OPTIONS = [
    ResultOrdering.new('relevancy desc', [:_score, :desc], 'Most Relevant'),
    ResultOrdering.new('relevancy asc', [:_score, :asc], 'Least Relevant'),
    ResultOrdering.new('date desc', [:date, :desc], 'Date Published - newest'),
    ResultOrdering.new('date asc', [:date, :asc], 'Date Published - oldest')
  ].freeze

  HIGHLIGHTS = [].freeze

  def define_elasticsearch_mapping
    settings do
      mappings dynamic: false do
        # fields
        indexes :title, type: 'text'
        indexes :description, type: 'text'
        indexes :source, type: 'text'
        indexes :document_type, type: 'text'
        indexes :date, type: 'date'
      end
    end
  end

  def self.visible_qualifiers
    { published: true }
  end
end
