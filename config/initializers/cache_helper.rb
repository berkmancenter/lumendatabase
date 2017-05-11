module ActionView
  module Helpers
    module CacheHelper
      def cache_fragment_name(name = {}, options = nil)
        skip_digest = options && !options[:skip_digest].nil? ? options[:skip_digest] : true

        if skip_digest
          name
        else
          fragment_name_with_digest(name)
        end
      end
    end
  end
end

