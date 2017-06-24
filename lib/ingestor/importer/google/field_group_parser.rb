module Ingestor
  module Importer
    class Google < Base
      class FieldGroupParser
        def initialize(field_group)
          @key = field_group.key
          @content = field_group.content
        end

        def description
          if @content.match(/field_group_#{@key}_work_description:(.+?)field_group_#{@key}/m)
            $1.strip
          end
        end

        def copyrighted_urls
          urls = @content.scan(/field_group_#{@key}_copyright_work_url_\d+:(.+)$/)
          urls.flatten.uniq.compact
        end

        def infringing_urls
          urls = @content.scan(/field_group_#{@key}_infringement_url_\d+:(.+)$/)
          urls.flatten.uniq.compact
        end
      end
    end
  end
end
