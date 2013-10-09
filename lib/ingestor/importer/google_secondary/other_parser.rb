require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class OtherParser < Base

        handles_content(/IssueType:\s?lr_legalother/m)

        def parse_works(file_path)
          content = IssueContent.new(
            file_path, 'legalother_explain'
          )

          [content.to_work]
        end

        def notice_type
          Other
        end

      end
    end
  end
end
