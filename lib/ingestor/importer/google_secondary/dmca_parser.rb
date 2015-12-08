require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class DMCAParser < Base

        handles_content(/IssueType:\s?lr_dmca/m)

        def parse_works(file_path)
          content = IssueContent.new(
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
          get_single_line_field(content, 'full_name')
        end

        def principal(content)
          get_single_line_field(content, 'represented_copyright_holder')
        end

      end
    end
  end
end
