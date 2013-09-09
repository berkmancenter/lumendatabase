module Ingestor
  module Importer
    class Google
      class FieldGroupParser
        def initialize(field_group, content)
          @field_group = field_group
          @content = content
        end

        def description
          if @content.match(/field_group_#{@field_group}_work_description:(.+?)field_group_#{@field_group}/m)
            $1.strip
          end
        end

        def copyrighted_urls
          urls = @content.scan(/field_group_#{@field_group}_copyright_work_url_\d+:(.+)$/)
          urls.flatten.uniq.compact
        end

        def infringing_urls
          urls = @content.scan(/field_group_#{@field_group}_infringement_url_\d+:(.+)$/)
          urls.flatten.uniq.compact
        end
      end
    end
  end
end
