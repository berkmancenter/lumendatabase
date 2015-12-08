module Ingestor
  class Legacy
    class AttributeMapper

      attr_reader :hash

      class ExcludedNoticeError < StandardError
        def initialize(reason)
          super("Notice was excluded because #{reason}")
        end
      end

      READLEVELS = {
        '3' => :hidden,
        '8' => :hidden,
        '9' => :spam,
        '10' => :rescinded
      }

      delegate :default_submitter, :default_recipient, :notice_type, :entities, to: :importer

      def initialize(hash)
        @hash = hash
        @importer = ImportDispatcher.for(
          @hash['OriginalFilePath'],
          @hash['SupportingFilePath']
        )

        check_exclusions!
      end

      def mapped
        body = importer.body
        body_original = importer.body_original

        body = hash['Body'] unless body.present?
        body_original = hash['BodyOriginal'] unless body_original.present?

        works = importer.works

        if works.empty?
          works = [Work.unknown]

          review_required = importer.require_review_if_works_empty?

        else
          review_required = false
        end

        {
          original_notice_id: hash['NoticeID'],
          title: title,
          subject: hash_text( 'Re_Line' ),
          source: hash['How_Sent'],
          action_taken: importer.action_taken,
          created_at: find_created_at,
          updated_at: hash['alter_date'],
          date_sent: hash['Date'],
          date_received: hash['Date'],
          file_uploads: importer.file_uploads,
          works: works,
          review_required: review_required,
          topics: topics(hash['CategoryName']),
          rescinded: rescinded?,
          hidden: ( importer.hidden? || hidden? ),
          submission_id: hash['SubmissionID'],
          entity_notice_roles: entity_notice_roles,
          body: body,
          body_original: body_original,
          mark_registration_number: importer.mark_registration_number
        }
      end

      private

      attr_reader :importer

      def hash_text( key )
        hash[ key ].split( "\n" ).first.strip unless hash[ key ].nil?
      end

      def title
        (
          normalize_title( hash_text( 'Subject' ) ) ||
          normalize_title( hash_text( 'Re_Line' ) )
        ) || 'Untitled'
      end

      def normalize_title(string)
        if string.respond_to?(:strip)
          string.strip.present? && string.strip
        else
          string
        end
      end

      def topics(topic_name)
        Topic.where(name: topic_name)
      end

      def find_created_at
        if [nil, '0000-00-00 00:00:00'].include?(hash['add_date'])
          hash['alter_date']
        else
          hash['add_date']
        end
      end

      def entity_notice_roles
        transform_entity_names([
          build_role('sender', 'Sender_LawFirm', 'Sender'),
          build_role('recipient', 'Recipient_Entity', 'Recipient'),
          build_role('principal', 'Sender_Principal', nil),
          build_role('attorney', 'Sender_Attorney', nil),
        ].compact)
      end

      def build_role(role_name, name_key, address_key)
        builder = EntityNoticeRoleBuilder.new(
          self, role_name, name_key, address_key
        )
        builder.build
      end

      def rescinded?
        READLEVELS[readlevel] == :rescinded
      end

      def hidden?
        READLEVELS[readlevel] == :hidden
      end

      def check_exclusions!
        if spam_readlevel?
          raise ExcludedNoticeError, "Readlevel indicated spam"
        end

        if spam_sender?
          raise ExcludedNoticeError, "Sender is blacklisted"
        end
      end

      def spam_readlevel?
        READLEVELS[readlevel] == :spam
      end

      def spam_sender?
        sender = hash['Sender_Principal'] or return false
        recipient = hash['Recipient_Entity'] or return false

        recipient =~ /^Google\b/ && (
          sender == "Stephen Darori" ||
          sender =~ /^(http:\/\/|www\.)linda/
        )
      end

      def readlevel
        hash['Readlevel'].to_s
      end

      def transform_entity_names(entity_notice_roles)
        if has_sender_and_principal?(entity_notice_roles)
          entity_notice_roles.map do |role|
            if role.name == 'sender'
              normalize_sender_name(role.entity)
              role
            else
              role
            end
          end
        else
          entity_notice_roles
        end
      end

      def normalize_sender_name(entity)
        entity.name = entity.name.split(/on behalf of/i)[0].strip
      end

      def has_sender_and_principal?(entity_notice_roles)
        role_names = entity_notice_roles.collect { |role| role.name }
        wanted_role_names = ['sender', 'principal']
        role_names.each_cons(wanted_role_names.length).include?(wanted_role_names)
      end

    end
  end
end
