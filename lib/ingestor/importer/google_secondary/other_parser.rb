require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class OtherParser < Base

        handles_content(/IssueType:\s?lr_legalother/m)

        def self.notice_type
          Other
        end

        def body
          '[REDACTED]'
        end

        def body_original
          content = RedactedContent.new(file_path, 'legalother_explain') do |c|
            "#{sender(c)} #{principal(c)}"
          end

          content.desciption
        end

        def parse_works(file_path)
          []
        end

        def notice_type
          self.class.notice_type
        end

        def default_recipient
          'Google, Inc.'
        end

        private

        def sender(content)
          get_single_line_field(content, 'full_name')
        end

        def principal(content)
          get_single_line_field(content, 'representedrightsholder')
        end

      end
    end
  end
end
