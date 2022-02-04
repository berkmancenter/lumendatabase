# Monkeypatch 1 start
# We are only interested in attributes, don't need any metadata  included
module FastJsonapi
  module SerializationCore
    class_methods do
      def record_hash(record, fieldset, includes_list, params = {})
        if cache_store_instance
          cache_opts = record_cache_options(cache_store_options, fieldset, includes_list, params)
          record_hash = cache_store_instance.fetch(record, **cache_opts) do
            temp_hash = attributes_hash(record, fieldset, params)
            temp_hash
          end
        else
          record_hash = attributes_hash(record, fieldset, params)
        end

        record_hash
      end
    end
  end
end
# MonkeyPatch 1 end
