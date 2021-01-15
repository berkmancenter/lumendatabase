require 'yt_importer/mapping/html/base'

module YtImporter
  module Mapping
    module Html
      class Defamation < Base
        NOTICE_TYPE_LABEL = 'Defamation'

        def notice_type
          ::Defamation
        end

        private

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
