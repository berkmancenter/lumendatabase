require 'yt_importer/mapping/html/trademark_d'

module YtImporter
  module Mapping
    module Html
      class Counterfeit < TrademarkD
        NOTICE_TYPE_LABEL = 'Counterfeit'

        private

        def work_description
          data_field_without_field_label(@notice_paragraphs.fetch(@urls_index + 1, nil)&.content)
        end

        def sender
          name = [
            data_field_without_field_label(@notice_paragraphs.fetch(1, nil)&.content),
            data_field_without_field_label(@notice_paragraphs.fetch(2, nil)&.content)
          ].reject { |val| val.blank? }.join(', ').strip

          build_role('sender', name)
        end

        def principal
          name = @notice_paragraphs.fetch(5, nil)&.content

          return nil if name.nil?

          name = data_field_without_field_label(name)

          build_role('principal', name)
        end
      end
    end
  end
end
