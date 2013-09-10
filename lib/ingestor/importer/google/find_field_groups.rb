module Ingestor
  module Importer
    class Google < Base
      class FindFieldGroups

        FieldGroup = Struct.new(:key, :content)

        def initialize(content)
          @content = content
          @keys = find_keys
        end

        def find
          keys.map { |key| FieldGroup.new(key, extract_content(key)) }
        end

        private

        attr_reader :keys, :content

        def find_keys
          field_groups = content.scan(/field_group_(\d+?)/)
          field_groups.flatten.compact.uniq.map(&:to_i)
        end

        def extract_content(key)
          if key == keys.last
            terminator = "field_signature"
          else
            terminator = "field_group_#{key + 1}"
          end

          pattern = /(field_group_#{key}_work_description.+?)#{terminator}/m
          content.match(pattern)

          $1.strip
        end
      end
    end
  end
end
