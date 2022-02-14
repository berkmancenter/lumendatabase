# frozen_string_literal: true

module Searchability
  def self.included(base)
    base.extend ClassMethods
  end

  # Default fields to search with a multimatch query. Weights some of the
  # fields, based purely on intuition from reading logs.
  # Before Elasticsearch 6.x this was an `_all` query, but `_all` is no longer
  # supported. Instead, we define base_search and preferred_search fields which
  # contain all the fields we actually searched via _all, and copy fields to
  # those during indexing (in a mutually exclusive way: fields get copied to
  # one or the other, not both). This lets us do simple weighting.
  # We could simply list all of the fields we would have searched, but that
  # scoring proves to be incredibly slow.
  MULTI_MATCH_FIELDS = %w(base_search preferred_search^2)

  module ClassMethods
    def define_elasticsearch_mapping(exclusions = {})
      index_name [Rails.application.engine_name,
                  Rails.env,
                  'notice',
                  ENV['ES_INDEX_SUFFIX']].compact.join('_')

      settings do
        mappings dynamic: false do
          # fields
          indexes :base_search, type: 'text'
          indexes :preferred_search, type: 'text'
          indexes :id, type: 'keyword'
          indexes :class_name, type: 'keyword'
          indexes :title, copy_to: 'preferred_search'
          indexes :date_received, type: 'date'
          indexes :created_at, type: 'date'
          indexes :rescinded, type: 'boolean'
          indexes :spam, type: 'boolean'
          indexes :published, type: 'boolean'
          indexes :hidden, type: 'boolean'
          indexes :subject, copy_to: 'base_search'
          indexes :body, copy_to: 'base_search'
          indexes :tag_list, copy_to: 'base_search'
          indexes :jurisdiction_list, copy_to: 'base_search'
          indexes :action_taken, type: 'keyword'
          indexes :request_type, type: 'keyword', copy_to: 'base_search'
          indexes :mark_registration_number, type: 'keyword', copy_to: 'base_search'
          indexes :sender_name, copy_to: 'preferred_search'
          indexes :principal_name, copy_to: 'base_search'
          indexes :submitter_name, copy_to: 'base_search'
          indexes :submitter_country_code, copy_to: 'base_search'
          indexes :recipient_name, copy_to: 'preferred_search'
          indexes :topics do
            indexes :name, copy_to: 'base_search'
          end
          indexes :works do
            indexes :description, copy_to: 'preferred_search'
            indexes :infringing_urls do
              indexes :url, copy_to: 'base_search'
            end
            indexes :copyrighted_urls do
              indexes :url, copy_to: 'base_search'
            end
          end
          indexes :entities_country_codes, type: 'keyword'

          # facets
          indexes :sender_name_facet, type: 'keyword'
          indexes :principal_name_facet, type: 'keyword'
          indexes :submitter_name_facet, type: 'keyword'
          indexes :submitter_country_code_facet, type: 'keyword'
          indexes :tag_list_facet, type: 'keyword'
          indexes :jurisdiction_list_facet, type: 'keyword'
          indexes :recipient_name_facet, type: 'keyword'
          indexes :country_code_facet, type: 'keyword'
          indexes :language_facet, type: 'keyword'
          indexes :action_taken_facet, type: 'keyword'
          indexes :topic_facet, type: 'keyword'
          indexes :date_received_facet, type: 'date'
        end
      end

      # the "as" attribute is not implemented in elasticsearch-rails
      # according to https://github.com/elastic/elasticsearch-rails/issues/21
      # it's the best workaround
      define_method :as_indexed_json do |_options|
        out = as_json(except: [:jurisdiction_list, :regulation_list, :tag_list, :works_json])

        attributes_to_skip = %w[review_required reviewer_id url_count
                                webform notes views_overall views_by_notice_viewer
                                works_json]
        out.except!(*attributes_to_skip)

        out['class_name'] = self.class.name
        out['sender_name_facet'] = sender_name
        out['sender_name'] = sender_name
        out['principal_name_facet'] = principal_name
        out['principal_name'] = principal_name
        out['submitter_name_facet'] = submitter_name
        out['submitter_name'] = submitter_name
        out['submitter_country_code_facet'] = submitter_country_code
        out['submitter_country_code'] = submitter_country_code
        out['tag_list_facet'] = tags.collect(&:name)
        out['tag_list'] = tags.collect(&:name)
        out['date_received_facet'] = date_received
        out['jurisdiction_list_facet'] = jurisdictions.collect(&:name)
        out['jurisdiction_list'] = jurisdictions.collect(&:name)
        out['recipient_name_facet'] = recipient_name
        out['recipient_name'] = recipient_name
        out['country_code_facet'] = country_code
        out['language_facet'] = language
        out['action_taken_facet'] = action_taken
        out['topic_facet'] = topics.map(&:name)
        out['topics'] = topics.map do |topic|
          { id: topic[:id], name: topic[:name] }
        end
        out['works'] = works.map do |work|
          {
            description: work.description,
            infringing_urls: work.infringing_urls.map { |iurl| { url: iurl.url } },
            copyrighted_urls: work.copyrighted_urls.map { |curl| { url: curl.url } }
          }
        end
        out['entities_country_codes'] = entities_country_codes

        out
      end
    end
  end
end
