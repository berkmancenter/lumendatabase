module Ingestor
  module Importer
    module GoogleSecondary
      class IssueContent

        def initialize(file_path, description_start)
          @content = Base.read_file(file_path)
          @description_start = description_start
        end

        def to_work
          Work.new(
            description: description,
            infringing_urls_attributes: infringing_urls,
            copyrighted_urls_attributes: copyrighted_urls
          )
        end

        def description
          if content.match(/#{description_start}[^:]*:(.+?)\n[a-z_]+:/m)
            $1.strip
          end
        end

        def copyrighted_urls
          description_urls = extract_urls(description)
          content.match(/location_of_copyrighted_work:(.+?)\n[a-z_]+:/m)
          location_urls = extract_urls($1)
          description_urls + location_urls
        end

        def infringing_urls
          content.match(/url_box.+?:(.+?)(\n\n|\r\n\r\n|\Z)/m)
          extract_urls($1)
        end

        private

        attr_reader :content, :description_start

        def extract_urls(string)
          URI::extract(string || '').
            select { |url| url.match(/\Ahttps?/i) }.
            map { |url| { url: url} }
        end

      end
    end
  end
end

