Dir['lib/ingestor/**/*.rb'].each do |file_path|
  require file_path.sub(/lib\/(.*)\.rb/, '\1')
end

module Ingestor
  ImportDispatcher.register(Importer::Google)
  ImportDispatcher.register(Importer::GoogleSecondary)
  ImportDispatcher.register(Importer::Twitter)
  ImportDispatcher.register(Importer::NullImporter)
end
