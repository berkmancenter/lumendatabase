require 'yt_importer/mapping/base'

module YtImporter
  module Mapping
    module PlainNew
      class Base < Base
        private

        def get_single_line_field(field_name)
          Regexp.last_match(1).strip if @notice_text.match(/^#{field_name}:(.+?)\n/)
        end

        def get_naive_multiline_field(start_token, end_token)
          Regexp.last_match(1).strip if @notice_text.match(/#{start_token}(.+?)#{end_token}/m)
        end

        def parsed_original_urls
          @notice_text.scan(/hyperlink:\s*(.+)\n/).flatten
        end
      end
    end
  end
end
