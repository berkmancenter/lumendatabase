require 'ingestor/works_importer/dispatcher'
require 'ingestor/works_importer/google'
require 'ingestor/works_importer/null_importer'
require 'ingestor/legacy_csv'

module Ingestor
end

Ingestor::WorksImporter::Dispatcher.register(Ingestor::WorksImporter::Google)
Ingestor::WorksImporter::Dispatcher.register(Ingestor::WorksImporter::NullImporter)
