require 'zlib'
require 'ingestor'

module Ingestor
  class LegacyCsv
    include Enumerable

    def self.open(file_path)
      new(file_path)
    end

    def initialize(file_path)
      @file_path = file_path
    end

    def import
      self.each do |csv_row|
        Dmca.create!(
          AttributeMapper.transform(csv_row)
        )
      end
    end

    def each(&block)
      CSV.foreach(@file_path, headers: true, &block)
    end
  end

  private

  class AttributeMapper
    def self.transform(csv_row)
      hash = csv_row.to_hash
      {
        original_notice_id: hash['NoticeID'],
        title: hash['Subject'],
        works: Ingestor::WorksImporter::Dispatcher.import(hash['OriginalFilePath']),
        entity_notice_roles: [
          EntityNoticeRole.new(
            name: 'sender',
            entity: Entity.new(name: hash['Sender_Principal'])
          ),
          EntityNoticeRole.new(
            name: 'recipient',
            entity: Entity.new(name: hash['Recipient_Entity'])
          ),
        ]
      }
    end
  end
end
