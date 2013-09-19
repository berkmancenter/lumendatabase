require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class BloggerParser < Base

        handles_content(/IssueType:\s?blogger_dmca_infringment/m)

        def parse_works(file_path)
          content = self.class.read_file(file_path)

          [Work.new(
            description: parse_description(content),
            infringing_urls: parse_urls(content)
          )]
        end

        private

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

      end
    end
  end
end

