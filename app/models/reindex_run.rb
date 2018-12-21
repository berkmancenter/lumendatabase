class ReindexRun < ActiveRecord::Base
  REINDEXED_MODELS = [Notice, Entity].freeze

  def self.index_changed_model_instances
    this_run = ReindexRun.create!

    metadata = {}
    REINDEXED_MODELS.each do |model|
      metadata[model.name] = this_run.index_model_for(model)
    end

    this_run.apply_metadata(metadata)

    sweep_search_result_caches
  rescue => e
    Rails.logger.error "Indexing did not succeed because: #{e.inspect}"
  end

  def self.sweep_search_result_caches
    ApplicationController.new.expire_fragment(/search-result-[a-f0-9]{32}/)
  end

  def self.indexed?(klass, id)
    client = klass.__elasticsearch__.client
    client.get(index: klass.index_name, id: id)['found'] rescue false
  end

  # The offset is needed to get the run previous to the current one.
  def last_run
    self.class.order('created_at').offset(1).last
  end

  def index_model_for(model)
    count = 0
    batch_size = (ENV['BATCH_SIZE'] || 100).to_i
    updateable_set(model).find_in_batches(batch_size: batch_size) do |instances|
      instances.each do |instance|
        instance.__elasticsearch__.index_document
        count += 1
      end
    end
    count
  end

  def apply_metadata(metadata)
    attrs = metadata.map { |k, v| ["#{k.name.downcase}_count", v] }.to_h
    attrs[updated_at] = Time.now
    update_attributes(attrs)
  end

  private

  def last_run_time
    @last_run_time ||= begin
      last_run&.created_at || 100.years.ago
    end
  end

  def updateable_set(model)
    model.where('updated_at > ? or updated_at is null', last_run_time)
  end
end
