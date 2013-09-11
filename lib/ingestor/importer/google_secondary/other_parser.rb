require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class OtherParser < Base

        handles_content(/IssueType:\s?lr_legalother2/m)

        def parse_works(file_path)
          content = IssueContent.new(
            file_path, 'legalother_explain', 'legalother_quote'
          )

          content.to_work
        end

        def original?(file_path)
          File.open(file_path) { |f| f.grep(/^IssueType:/) }.present?
        end

        def notice_type
          Other
        end

      end
    end
  end
end
