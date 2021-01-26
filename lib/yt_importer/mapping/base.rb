require 'yt_importer/entity_notice_role_builder'

module YtImporter
  module Mapping
    class Base
      attr_accessor :data_from_legacy_database

      READLEVELS = {
        '3' => :hidden,
        '8' => :hidden,
        '9' => :spam,
        '10' => :rescinded
      }

      def initialize(notice_text, data_from_legacy_database, raw_file_path)
        @notice_text = notice_text
        @data_from_legacy_database = data_from_legacy_database
        @raw_file_path = raw_file_path
        @notice_type = DMCA
      end

      def notice_type
        DMCA
      end

      def title
        "Takedown Request regarding #{self.class::NOTICE_TYPE_LABEL} Complaint to YouTube"
      end

      def entity_notice_roles
        roles = [
          google_entity_role('submitter'),
          google_entity_role('recipient')
        ]

        roles << sender if sender
        roles << principal if principal
        roles << attorney if attorney

        roles
      end

      def file_uploads
        [FileUpload.new(
          kind: 'original',
          file: File.open(@raw_file_path)
        )]
      end

      def hidden?
        READLEVELS[readlevel] == :hidden
      end

      def rescinded?
        READLEVELS[readlevel] == :rescinded
      end

      def mark_registration_number
        mark_registration_number = parse_mark_registration_number(@raw_file_path)
        return mark_registration_number if mark_registration_number.present?

        ''
      end

      def works
        works = parse_works
        return works if works.any?

        []
      end

      def subject
        "Youtube video"
      end

      def topics
        Topic.where(name: self.class::NOTICE_TYPE_LABEL)
      end

      def source
        'Youtube Legal Support'
      end

      def tag_list
        'youtube'
      end

      def action_taken
        ''
      end

      def body
        ''
      end

      def body_original
        ''
      end

      private

      def readlevel
        @data_from_legacy_database['Readlevel'].to_s
      end

      def parse_mark_registration_number(*)
      end

      def sender(*)
      end

      def sender_address(*)
      end

      def principal(*)
      end

      def recipient(*)
      end

      def attorney(*)
      end

      def data_field_without_field_label(field_content)
        field_content&.split(':', 2)&.last&.strip
      end

      def read_file(file)
        content = IO.read(file)
        if !content.valid_encoding?
          content.unpack("C*").pack("U*")
        else
          content
        end
      end

      def google_entity_role(role_name)
        EntityNoticeRole.new(
          entity: Entity.where(name: 'Google LLC').first,
          name: role_name
        )
      end

      def build_role(role_name, name, address = nil)
        builder = EntityNoticeRoleBuilder.new(
          role_name, name, address
        )
        builder.build
      end

      def work_description
        ''
      end

      def parse_works
        infringing_urls = parsed_infringing_urls.map do |url|
          uri = URI.parse(url)
          valid = %w(http https).include?(uri.scheme)
          unless valid
            url = "https://#{url}"
          end

          InfringingUrl.new(url: url)
        end
        [
          Work.new(
            description: work_description,
            infringing_urls: infringing_urls
          )
        ]
      end
    end
  end
end
