require 'ingestor/importer/base'

module Ingestor
  module Importer
    module GoogleSecondary
      class OtherParser < Base

        handles_content(/IssueType:\s?lr_legalother/m)

        def self.notice_type
          Defamation
        end

        def body
          content = RedactedContent.new(original_file_paths.first, 'legalother_explain') do |c|
            redact_with = "deadbeef #{sender(c)} #{principal(c)}".strip
            Rails.logger.debug "[importer][other] redact body: '#{redact_with}'"
            redact_with
          end

          content.to_work.description
        end

        def body_original
          content = RedactedContent.new(original_file_paths.first, 'legalother_explain') do |c|
            "#{sender(c)} #{principal(c)}".strip
          end

          content.to_work.description_original
        end

        def hidden?
          false
        end

        def parse_date( str, format )
          Date.strptime( str, format ) rescue nil
        end

        def date_received
          content = Base.read_file(original_file_paths.first)

          Rails.logger.debug "[importer][other] signature_date:  #{get_single_line_field(content, 'signature_date')}"

          signature_date = get_single_line_field(content, 'signature_date')

          dr = parse_date signature_date, '%Y-%m-%d'

          if dr.nil?
            dr = parse_date signature_date, '%m/%d/%Y'
          end

          if dr.nil?
            dr = parse_date signature_date, '%m/%d/%y'
          end

          dr
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

        def tag_list
          content = Base.read_file(original_file_paths.first)

          get_single_line_field(content, 'hidden_product')
        end

        def default_submitter
          'Google Inc.'
        end

        def default_recipient
          'Google Inc.'
        end

        def review_required?
          false
        end

        def sender(content)
          Rails.logger.debug "[importer][other] sender:  #{get_single_line_field(content, 'full_name')}"
          get_single_line_field(content, 'full_name')
        end

        def sender_address()
          content = Base.read_file(original_file_paths.first)

          {
            country_code: get_single_line_field(content, 'country_residence')
          }
        end

        def principal(content)
          Rails.logger.debug "[importer][other] principal:  #{get_single_line_field(content, 'representedrightsholder')}"
          get_single_line_field(content, 'representedrightsholder')
        end

      end
    end
  end
end
