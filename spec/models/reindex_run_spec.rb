require 'spec_helper'

describe ReindexRun, type: :model do

  it "tracks run information when no exceptions are thrown" do
    reindex_run = build(:reindex_run)
    expect(ReindexRun).to receive(:create!).and_return(reindex_run)
    now = Time.now
    allow(Time).to receive(:now).and_return(now)

    expect(reindex_run).to receive(:update_attributes).with(
      notice_count: 0, entity_count: 0, updated_at: now
    )
    described_class.index_changed_model_instances
  end

  it "does not track run information when exceptions are thrown" do
    expect(ReindexRun).not_to receive(:create!).with(entity_count: 0, notice_count: 0)
    allow(Notice).to receive(:where).and_raise(StandardError)

    described_class.index_changed_model_instances
  end

  context ".last_run" do
    it "equals the last run" do
      first_run = create(:reindex_run)
      last_run = Timecop.travel(1.hour) { create(:reindex_run) }

      expect(described_class.last_run).to eq last_run
    end
  end

  context "entities" do
    it "only reindexes changed entities" do
      create(:reindex_run)

      old_entity = Timecop.travel(1.hour.ago) { create(:entity, name: 'Old') }
      new_entity = Timecop.travel(1.hour) { create(:entity, name: 'New') }

      expect_any_instance_of(Entity).to receive(:tire).once.and_return(tire_proxy)

      described_class.index_changed_model_instances
    end
  end

  context "notices" do
    it "only reindexes changed notices" do
      create(:reindex_run)

      old_entity = Timecop.travel(1.hour.ago) { create(:dmca, title: 'Old') }
      new_entity = Timecop.travel(1.hour) { create(:dmca, title: 'New') }

      expect_any_instance_of(Notice).to receive(:tire).once.and_return(tire_proxy)

      described_class.index_changed_model_instances
    end
  end

  def tire_proxy
    double('Tire proxy', update_index: true)
  end
end
