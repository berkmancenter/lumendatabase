# frozen_string_literal: true

require 'rails_admin/config'
require 'rails_admin/config/fields/base'

module RailsAdmin
  module Config
    module Fields
      module AssociationNoCount
        # In the original version it runs .count for every association field
        # which is too intensive in our case
        def associated_collection_cache_all
          false
        end
      end
    end
  end
end