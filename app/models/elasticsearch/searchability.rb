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
  end
end
