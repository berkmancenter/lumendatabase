require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class EbDMCAParser < Base

        handles_content(/IssueType:\s?eb_dmca/m)

        def parse_works(file_path)
          content = EbIssueContent.new(
            file_path, 'description_of_copyrighted_work'
          )

          [content.to_work]
        end

        def default_submitter
          'Google, Inc.'
        end

        def default_recipient
          'Google, Inc.'
        end

        private

        def sender(content)
          [
            get_single_line_field(content, 'first_name'),
            get_single_line_field(content, 'last_name')
          ].compact.uniq.join(' ').strip
        end

        def principal(content)
          get_single_line_field(content, 'dmca_company_name')
        end

      end
    end
  end
end
