module Ingestor
  module Importer
    class Base

      def self.handles_content(regex)
        @content_regex = regex
      end

      def self.handles?(file_paths)
        return false unless @content_regex

        file_paths && file_paths.split(',').any? do |file|
          File.exists?(file) && text?(file) && contains?(file, @content_regex)
        end
      end

      def self.text?(file_name)
        MIME::Types.type_for(file_name).find do |type|
          type.content_type.match(/\Atext\/.+/)
        end
      end

      def self.contains?(file, regex)
        read_file(file).split(/\r?\n/).detect { |line| line =~ regex }
      end

      def self.read_file(file)
        content = IO.read(file)
        if ! content.valid_encoding?
          content.unpack("C*").pack("U*")
        else
          content
        end
      end

      attr_reader :original_file_paths, :supporting_file_paths, :notice_type

      def initialize(original_file_paths, supporting_file_paths = nil)
        @original_file_paths = fix_paths(original_file_paths)
        @supporting_file_paths = fix_paths(supporting_file_paths)
        @notice_type = DMCA
      end

      def entities
        file_paths.each do |file_path|
          if parsable?(file_path)
            entities = parse_entities(file_path)
            entities.any? and return entities
          end
        end

        {}
      end

      def mark_registration_number
        file_paths.each do |file_path|
          if parsable?(file_path)
            mark_registration_number = parse_mark_registration_number(file_path)
            mark_registration_number.present? and return mark_registration_number
          end
        end

        ''
      end

      def body
        nil
      end

      def body_original
        nil
      end

      def hidden?
	    false
      end

      def works
        file_paths.each do |file_path|
          if parsable?(file_path)
            works = parse_works(file_path)
            works.any? and return works
          end
        end

        []
      end

      def parsable?(file_path)
        self.class.text?(file_path)
      end

      def parse_works(file_path)
        raise NotImplementedError, "#{self.class} must implement #{__method__}"
      end

      def parse_entities(file_path)
        content = self.class.read_file(file_path)
        entities = {}
        sender(content).present? && entities[:sender] = sender(content)
        principal(content).present? && entities[:principal] = principal(content)
        entities
      end

      def parse_mark_registration_number(*)
      end

      def sender(*)
      end

      def principal(*)
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

      def file_paths
        original_file_paths + supporting_file_paths
      end

      def file_uploads
        original_documents + supporting_documents
      end

      def action_taken
        ''
      end

      def default_submitter
      end

      def default_recipient
      end

      def review_required?
        false
      end

      def require_review_if_works_empty?
        true
      end

      private

      def fix_paths(file_paths)
        "#{file_paths}".split(',').select { |f| File.exists?(f) }
      end

      def get_single_line_field(content, field_name)
        if content.match(/^#{field_name}:(.+?)\r?\n/)
          $1.strip
        end
      end

      def get_naive_multiline_field(content, start_token, end_token)
        if content.match(/#{start_token}(.+?)#{end_token}/m)
          $1.strip
        end
      end

    end
  end
end
