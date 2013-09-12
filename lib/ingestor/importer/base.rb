module Ingestor
  module Importer
    class Base

      def self.handles_content(regex)
        @content_regex = regex
      end

      def self.handles?(file_paths)
        return false unless @content_regex

        file_paths && file_paths.split(',').any? do |file|
          text?(file) && contains?(file, @content_regex)
        end
      end

      def self.text?(file_name)
        MIME::Types.type_for(file_name).find do |type|
          type.content_type.match(/\Atext\/.+/)
        end
      end

      def self.contains?(file, regex)
        # http://stackoverflow.com/questions/9607554/ruby-invalid-byte-sequence-in-utf-8
        content = IO.read(file).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
        content.split(/\r?\n/).detect { |line| line =~ regex }
      end

      attr_reader :file_paths, :notice_type

      def initialize(file_paths)
        @file_paths = (file_paths || '').split(',')
        @notice_type = Dmca
      end

      def works
        original_file_paths.map { |file_path| parse_works(file_path) }.flatten
      end

      def parse_works(file_path)
        raise NotImplementedError, "#{self.class} must implement #{__method__}"
      end

      def original_documents
        original_file_paths.map do |file_path|
          FileUpload.new(
            kind: 'original',
            file: File.open(file_path)
          )
        end
      end

      def supporting_documents
        supporting_file_paths.map do |file_path|
          FileUpload.new(
            kind: 'supporting',
            file: File.open(file_path)
          )
        end
      end

      def file_uploads
        original_documents + supporting_documents
      end

      def original_file_paths
        file_paths.select { |file_path| original?(file_path) }
      end

      def supporting_file_paths
        file_paths.reject { |file_path| original?(file_path) }
      end

      def original?(file_path)
        File.extname(file_path) == '.txt'
      end

    end
  end
end
