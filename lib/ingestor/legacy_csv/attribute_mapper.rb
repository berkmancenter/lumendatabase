module Ingestor
  class LegacyCsv
    class AttributeMapper

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

      delegate :notice_type, to: :importer

      def initialize(hash)
        @hash = hash
        @importer = ImportDispatcher.for(
          @hash['OriginalFilePath'],
          @hash['SupportingFilePath']
        )

        check_exclusions!
      end

      def mapped
        works = importer.works

        if works.empty?
          works = [Work.unknown]
          review_required = true
        else
          review_required = false
        end

        {
          original_notice_id: hash['NoticeID'],
          title: hash['Subject'],
          subject: hash['Re_Line'],
          source: hash['How_Sent'],
          action_taken: importer.action_taken,
          created_at: hash['add_date'],
          updated_at: hash['alter_date'],
          date_sent: hash['Date'],
          date_received: hash['Date'],
          file_uploads: importer.file_uploads,
          works: works,
          review_required: review_required,
          topics: topics(hash['CategoryName']),
          rescinded: rescinded?,
          hidden: hidden?,
          submission_id: hash['SubmissionID'],
          entity_notice_roles: entity_notice_roles,
        }
      end

      private

      attr_reader :hash, :importer

      def topics(topic_name)
        Topic.where(name: topic_name)
      end

      def entity_notice_roles
        [
          build_role('sender', 'Sender_LawFirm', 'Sender'),
          build_role('recipient', 'Recipient_Entity', 'Recipient'),
          build_role('principal', 'Sender_Principal', nil),
          build_role('attorney', 'Sender_Attorney', nil),
        ].compact
      end

      def build_role(role_name, name_key, address_key)
        return unless hash[name_key].present?

        attributes = { name: hash[name_key] }

        if address_key
          attributes.merge!(address_hash(address_key))
        end

        EntityNoticeRole.new(name: role_name, entity_attributes: attributes)
      end

      def address_hash(prefix)
        {
          address_line_1: hash["#{prefix}_Address1"],
          address_line_2: hash["#{prefix}_Address2"],
          city: hash["#{prefix}_City"],
          state: hash["#{prefix}_State"],
          zip: hash["#{prefix}_Zip"],
          country_code: parse_country_code(hash["#{prefix}_Country"]),
        }
      end

      def parse_country_code(country_code)
        return country_code if country_code.nil?

        country_code.strip!

        if country_code.length == 2
          country_code
        else
          mapping[country_code] || country_code[0,2]
        end
      end

      def mapping
        {
          'United States' => 'US',
          'USA' => 'US',
        }
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

    end
  end
end
