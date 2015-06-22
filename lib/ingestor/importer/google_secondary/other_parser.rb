require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class OtherParser < Base

        handles_content(/IssueType:\s?lr_legalother/m)

        def parse_works(file_path)
          content = RedactedContent.new(
            file_path, 'legalother_explain'
          )

          [content.to_work]
        end

        def notice_type
          Other
        end

        def default_recipient
          'Google, Inc.'
        end

        private

        def sender(content)
          'REDACTED'
        end

        def principal(content)
          get_single_line_field(content, 'representedrightsholder')
        end

      end
    end
  end
end
