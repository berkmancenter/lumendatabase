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
          content = RedactedContent.new(original_file_paths.first, 'legalother_explain') do |c|
            "#{sender(c)} #{principal(c)}"
          end

          content.to_work.description
        end

        def body_original
          content = RedactedContent.new(original_file_paths.first, 'legalother_explain') do |c|
            "#{sender(c)} #{principal(c)}"
          end

          content.to_work.description_original
        end

        def hidden?
          true
        end

        def parse_works(file_path)
          content = RedactedContent.new(file_path, 'legalother_explain') do |c|
            "#{sender(c)} #{principal(c)}"
          end

          work = content.to_work
		  work.update_attributes description: '', description_original: ''
          [work]
        end

        def notice_type
          self.class.notice_type
        end

        def default_submitter
          'Google, Inc.'
        end

        def default_recipient
          'Google, Inc.'
        end

        def review_required?
          true
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
