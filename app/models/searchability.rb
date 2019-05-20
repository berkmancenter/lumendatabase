# frozen_string_literal: true

module Searchability
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def define_elasticsearch_mapping(exclusions = {})
      index_name [Rails.application.engine_name,
                  Rails.env,
                  'notice',
                  ENV['ES_INDEX_SUFFIX']].compact.join('_')
      document_type 'notice'

      settings do
        mapping do
          # fields
          indexes :id, index: 'not_analyzed', include_in_all: false
          indexes :class_name, index: 'not_analyzed', include_in_all: false
          indexes :title
          indexes :date_received, type: 'date', include_in_all: false
          indexes :rescinded, type: 'boolean', include_in_all: false
          indexes :spam, type: 'boolean', include_in_all: false
          indexes :published, type: 'boolean', include_in_all: false
          indexes :hidden, type: 'boolean', include_in_all: false
          indexes :tag_list
          indexes :jurisdiction_list
          indexes :action_taken, analyzer: 'keyword'
          indexes :request_type, analyzer: 'keyword'
          indexes :mark_registration_number, analyzer: 'keyword'
          indexes :sender_name
          indexes :principal_name
          indexes :submitter_name
          indexes :submitter_country_code
          indexes :recipient_name
          indexes :topics, type: 'object'
          indexes :works, type: 'object'

          # facets
          indexes :sender_name_facet, include_in_all: false, type: 'keyword'
          indexes :principal_name_facet, include_in_all: false, type: 'keyword'
          indexes :submitter_name_facet, include_in_all: false, type: 'keyword'
          indexes :submitter_country_code_facet, include_in_all: false, type: 'keyword'
          indexes :tag_list_facet, include_in_all: false, type: 'keyword'
          indexes :jurisdiction_list_facet, include_in_all: false, type: 'keyword'
          indexes :recipient_name_facet, include_in_all: false, type: 'keyword'
          indexes :country_code_facet, include_in_all: false, type: 'keyword'
          indexes :language_facet, include_in_all: false, type: 'keyword'
          indexes :action_taken_facet, include_in_all: false, type: 'keyword'
          indexes :topic_facet, include_in_all: false, type: 'keyword'
          indexes :date_received_facet, include_in_all: false, type: 'date'
        end
      end

      # the "as" attribute is not implemented in elasticsearch-rails
      # according to https://github.com/elastic/elasticsearch-rails/issues/21
      # it's the best workaround
      define_method :as_indexed_json do |options|
        exclusions[:works] ||= []

        out = as_json

        out['class_name'] = self.class.name
        out['sender_name_facet'] = sender_name
        out['sender_name'] = sender_name
        out['principal_name_facet'] = principal_name
        out['principal_name'] = principal_name
        out['submitter_name_facet'] = submitter_name
        out['submitter_name'] = submitter_name
        out['submitter_country_code_facet'] = submitter_country_code
        out['submitter_country_code'] = submitter_country_code
        out['tag_list_facet'] = tag_list
        out['tag_list'] = tag_list
        out['date_received_facet'] = date_received
        out['jurisdiction_list_facet'] = jurisdiction_list
        out['jurisdiction_list'] = jurisdiction_list
        out['recipient_name_facet'] = recipient_name
        out['recipient_name'] = recipient_name
        out['country_code_facet'] = country_code
        out['language_facet'] = language
        out['action_taken_facet'] = action_taken
        out['topic_facet'] = topics.map(&:name)
        out['topics'] = topics.map do |topic|
          { id: topic[:id], name: topic[:name] }
        end
        out['works'] = works.as_json(
          only: [:description] - exclusions[:works],
          include: {
            infringing_urls: { only: [:url] },
            copyrighted_urls: { only: [:url] }
          }
        )

        out
      end
    end
  end
end
