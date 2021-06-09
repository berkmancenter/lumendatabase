require 'yt_importer/mapping/plain_new/trademark_d'

module YtImporter
  module Mapping
    module PlainNew
      class OtherLegal < TrademarkD
        NOTICE_TYPE_LABEL = 'Other Legal'

        def notice_type
          ::Other
        end

        def regulation_list
          regulations = get_single_line_field('cite_law')

          return [] if regulations.blank?

          regulations.split(',')
        end

        def jurisdiction
          jurisdictions = get_single_line_field('Country')

          return [] if jurisdictions.blank?

          jurisdictions.split(',')
        end

        private

        def parsed_infringing_urls
          urls = []

          %w[video_url comment_url channel_url other_url].each do |field|
            field_content = get_naive_multiline_field("#{field}:", 'content:')
            urls += URI.extract(field_content, %w[http https]) unless field_content.blank?
          end

          urls
        end

        def parsed_original_urls
          []
        end

        def work_description
          get_naive_multiline_field('content:', 'affirmation_one:')
        end

        def sender
          name = get_single_line_field('Signature')

          return nil if name.blank?

          build_role('sender', name)
        end

        def principal
          behalf_client = get_single_line_field('client')
          legal_name = get_single_line_field('Fulllegalname')

          name = legal_name if legal_name.present?
          name = behalf_client if behalf_client.present?

          return nil if name.blank?

          build_role('principal', name)
        end
      end
    end
  end
end
