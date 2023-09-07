# frozen_string_literal: true

module Searchability
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def load_elasticsearch_helpers(exclusions = {})
      index_name [Rails.application.engine_name,
                  Rails.env,
                  self.name.downcase,
                  ENV['ES_INDEX_SUFFIX']].compact.join('_')
    end

    def put_mapping
      self.__elasticsearch__.client.indices.put_mapping(
        index: index_name,
        type: self.__elasticsearch__.document_type,
        body: File.read(Rails.root.join('search', "#{self.name.downcase}_index_mapping.json"))
      )
    end
  end
end
