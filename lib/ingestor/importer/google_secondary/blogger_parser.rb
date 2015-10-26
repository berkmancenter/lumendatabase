require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class BloggerParser < Base

        handles_content(/IssueType:\s?blogger_dmca_infringement/m)

        def parse_works(file_path)
          content = self.class.read_file(file_path)

          [Work.new(
            description: parse_description(content),
            infringing_urls: parse_urls(content)
          )]
        end

        def default_recipient
          'Google, Inc. [Blogger]'
        end

        private

        def sender(content)
          [
            get_field(content, 'a01_first_name'),
            get_field(content, 'a02_last_name')
          ].uniq.compact.join(' ').strip
        end

        def principal(content)
          get_field(content, 'a04_copyright_holder').to_s.strip
        end

        def parse_description(content)
          parse_key(content, 'a06_copyrighted_work')
        end

        def parse_urls(content)
          urls = []

          %w( a07_infringing_URL a08_infringing_URL ).each do |key|
            if urls_string = parse_key(content, key)
              lines = urls_string.split(/\s+/)
              urls += lines.map { |line| line.sub(/<.*>$/, '') }
            end
          end

          urls.map { |url| InfringingUrl.new(url: url) }
        end

        def parse_key(content, key)
          next_number = key.sub(/a(\d{2})_/, '\1').to_i + 1
          next_key = "a#{"%02d" % next_number}_"

          if content.match(/^#{key}:\s*(.*)^#{next_key}/m)
            $1.strip
          end
        end

        def get_field(content, field_name)
          if content.match(/^#{field_name}:(.+?)a0\d+/m)
            $1.strip
          end
        end

      end
    end
  end
end

