Dir['lib/ingestor/**/*.rb'].sort_by { |file_path| file_path.split('/').length }.each do |file_path|
  require file_path.sub(/lib\/(.*)\.rb/, '\1')
end

module Ingestor
  ImportDispatcher.register(Importer::Google)
  ImportDispatcher.register(Importer::GoogleSecondary::DMCAParser)
  ImportDispatcher.register(Importer::GoogleSecondary::EbDMCAParser)
  ImportDispatcher.register(Importer::GoogleSecondary::BloggerParser)
  ImportDispatcher.register(Importer::GoogleSecondary::OtherParser)
  ImportDispatcher.register(Importer::Twitter)
  ImportDispatcher.register(Importer::Youtube::Defamation)
  ImportDispatcher.register(Importer::Youtube::TrademarkD)
  ImportDispatcher.register(Importer::Youtube::TrademarkB)
  ImportDispatcher.register(Importer::Youtube::Counterfeit)
  ImportDispatcher.register(Importer::Youtube::OtherLegal)
  ImportDispatcher.register(Importer::UnknownImporter)
end
