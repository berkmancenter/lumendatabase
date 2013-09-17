require 'ingestor/importer/google_secondary/issue_content'

module Ingestor
  module Importer
    module GoogleSecondary
      class EbIssueContent < IssueContent

        def infringing_urls
          content.match(/url_of_infringing_material:\s*(.*)/m)
          extract_urls($1)
        end

      end
    end
  end
end
