module Searchability
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def define_elasticsearch_mapping(exclusions = {})
      exclusions = Hash.new { |h, k| h[k] = [] }.merge(exclusions)
      mapping do
        indexes :id, index: 'not_analyzed', include_in_all: false
        indexes :class_name, index: 'not_analyzed', include_in_all: false,
          as: ->(notice) {notice.class.name}
        indexes :title
        indexes :date_received, type: 'date', include_in_all: false
        indexes :rescinded, type: 'boolean', include_in_all: false
        indexes :spam, type: 'boolean', include_in_all: false
        indexes :published, type: 'boolean', include_in_all: false
        indexes :hidden, type: 'boolean', include_in_all: false
        indexes :tag_list, as: 'tag_list'
        indexes :jurisdiction_list, as: 'jurisdiction_list'
        indexes :action_taken, analyzer: 'keyword'
        indexes :request_type, analyzer: 'keyword'
        indexes :mark_registration_number, analyzer: 'keyword'
        indexes :sender_name, as: 'sender_name'
        indexes :sender_name_facet,
          analyzer: 'keyword', as: 'sender_name',
          include_in_all: false
        indexes :principal_name, as: 'principal_name'
        indexes :principal_name_facet,
          analyzer: 'keyword', as: 'principal_name',
          include_in_all: false
        indexes :submitter_name, as: 'submitter_name'
        indexes :submitter_name_facet,
          analyzer: 'keyword', as: 'submitter_name',
          include_in_all: false
        indexes :submitter_country_code, as: 'submitter_country_code'
        indexes :submitter_country_code_facet,
          analyzer: 'keyword', as: 'submitter_country_code',
          include_in_all: false
        indexes :tag_list_facet,
          analyzer: 'keyword', as: 'tag_list',
          include_in_all: false
        indexes :jurisdiction_list_facet,
          analyzer: 'keyword', as: 'jurisdiction_list',
          include_in_all: false
        indexes :recipient_name, as: 'recipient_name'
        indexes :recipient_name_facet,
          analyzer: 'keyword', as: 'recipient_name', include_in_all: false
        indexes :country_code_facet,
          analyzer: 'keyword', as: 'country_code', include_in_all: false
        indexes :language_facet,
          analyzer: 'keyword', as: 'language', include_in_all: false
        indexes :action_taken_facet,
          analyzer: 'keyword', as: 'action_taken', include_in_all: false
        indexes :topics, type: 'object', as: 'topics'
        indexes :topic_facet,
          analyzer: 'keyword', as: ->(notice) { notice.topics.map(&:name) },
          include_in_all: false
        indexes :works,
          type: 'object',
          as: -> (notice){
            notice.works.as_json({
              only: [:description] - exclusions[:works],
              include: {
                infringing_urls: { only: [:url] },
                copyrighted_urls: { only: [:url]}
              }
            })
          }
      end
    end
  end
end
