# frozen_string_literal: true

namespace :lumen do
  desc 'Hide notices listed in INPUT_FILE by notice id or legacy submission id URL'
  task hide_notices_from_file: :environment do
    input_path = ENV['INPUT_FILE']

    if input_path.blank?
      abort <<~USAGE
        Usage: bundle exec rake lumen:hide_notices_from_file INPUT_FILE=/path/to/notice_ids.txt

        Optional environment variables:
          BATCH_SIZE=5000  Number of input lines handled per batch
          DRY_RUN=true     Count matching visible notices without changing them
      USAGE
    end

    batch_size = Integer(
      ENV.fetch('BATCH_SIZE', Lumen::Maintenance::HideNoticesFromFile::DEFAULT_BATCH_SIZE)
    )
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch('DRY_RUN', false))

    Lumen::Maintenance::HideNoticesFromFile.new(
      path: input_path,
      batch_size: batch_size,
      dry_run: dry_run
    ).call

    Lumen::Cache::Sweeper.sweep_search_result_caches unless dry_run
  end
end
