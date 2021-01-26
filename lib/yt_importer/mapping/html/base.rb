require 'nokogiri'
require 'yt_importer/mapping/base'

module YtImporter
  module Mapping
    module Html
      class Base < Base
        def initialize(notice_text, data_from_legacy_database, raw_file_path)
          @notice_parsed = Nokogiri::HTML(notice_text)
          @notice_paragraphs = @notice_parsed.css('p').to_a

          @urls_index = 0
          @notice_paragraphs.each do |paragraph|
            break if paragraph.content.include?('youtube.com/watch') || paragraph.content.include?('youtu.be/')

            @urls_index += 1
          end

          super
        end

        private

        def parsed_infringing_urls
          data_field_without_field_label(@notice_paragraphs.fetch(@urls_index, nil)&.content).split(/[\s,]/)
        end
      end
    end
  end
end
