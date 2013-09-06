module Ingestor
  module Importer
    class Google
      class FindFieldGroups
        def initialize(content)
          @content = content
          find_field_groups
        end

        def find
          field_groups = {}
          @field_groups.collect do |field_group|
            field_groups[field_group] = extract_field_group_content(field_group)
          end
          field_groups
        end

        private

        def find_field_groups
          field_groups = @content.scan(/field_group_(\d+?)/)
          @field_groups = field_groups.flatten.compact.uniq.map{|field_group| field_group.to_i}
        end

        def extract_field_group_content(field_group)
          next_field_group = field_group + 1
          terminator = "field_group_#{next_field_group}"

          if field_group == @field_groups.last
            terminator  = "field_signature"
          end

          pattern = /(field_group_#{field_group}_work_description.+?)#{terminator}/m
          @content.match(pattern)
          $1.strip
        end
      end
    end
  end
end
