require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class EbDmcaParser < Base

        handles_content(/IssueType:\s?eb_dmca/m)

        def parse_works(file_path)
          content = EbIssueContent.new(
            file_path, 'description_of_copyrighted_work', 'dmca_company_name'
          )

          [content.to_work]
        end

      end
    end
  end
end
