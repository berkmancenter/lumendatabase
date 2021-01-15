require 'yt_importer/mapping/html/trademark_d'

module YtImporter
  module Mapping
    module Html
      class OtherLegal < TrademarkD
        NOTICE_TYPE_LABEL = 'Other Legal'

        def notice_type
          ::Other
        end

        private

        def work_description
          [
            data_field_without_field_label(@notice_paragraphs.fetch(@urls_index + 1, nil)&.content),
            data_field_without_field_label(@notice_paragraphs.fetch(@urls_index + 2, nil)&.content),
            data_field_without_field_label(@notice_paragraphs.fetch(@urls_index + 3, nil)&.content)
          ].reject { |val| val.blank? }.join("\n").strip
        end

        def principal
          name = @notice_paragraphs.fetch(3, nil)&.content

          return nil if name.nil?

          name = data_field_without_field_label(name)

          build_role('principal', name)
        end

        def sender
          name = @notice_paragraphs.fetch(6, nil)&.content

          return nil if name.nil?

          name = data_field_without_field_label(name)

          build_role('sender', name)
        end
      end
    end
  end
end
