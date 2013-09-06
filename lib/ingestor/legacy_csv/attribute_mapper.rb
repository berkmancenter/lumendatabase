module Ingestor
  class LegacyCsv
    class AttributeMapper
      def initialize(hash)
        @hash = hash
      end

      def mapped
        importer = ImportDispatcher.for(hash['OriginalFilePath'])

        {
          original_notice_id: hash['NoticeID'],
          title: hash['Subject'],
          subject: hash['Re_Line'],
          source: hash['How_Sent'],
          created_at: hash['add_date'],
          updated_at: hash['alter_date'],
          date_sent: hash['Date'],
          date_received: hash['Date'],
          file_uploads: importer.file_uploads,
          works: importer.works,
          entity_notice_roles: [
            EntityNoticeRole.new(
              name: 'sender',
              entity: Entity.new({name: hash['Sender_Principal']}.merge(
                address_hash('Sender')
              ))
            ),
            EntityNoticeRole.new(
              name: 'recipient',
              entity: Entity.new({name: hash['Recipient_Entity']}.merge(
                address_hash('Recipient')
              ))
            ),
          ]
        }
      end

      private

      attr_reader :hash

      def address_hash(role_name)
        {
          address_line_1: hash["#{role_name}_Address1"],
          address_line_2: hash["#{role_name}_Address2"],
          city: hash["#{role_name}_City"],
          state: hash["#{role_name}_State"],
          zip: hash["#{role_name}_Zip"],
          country_code: parse_country_code(hash["#{role_name}_Country"]),
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
    end
  end
end
