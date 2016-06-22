require 'spec_helper'

describe ReindexRun, type: :model do

  it "tracks run information when no exceptions are thrown" do
    reindex_run = build(:reindex_run)
    ReindexRun.should_receive(:create!).and_return(reindex_run)
    now = Time.now
    Time.stub(:now).and_return(now)

    reindex_run.should_receive(:update_attributes).with(
      notice_count: 0, entity_count: 0, updated_at: now
    )
    described_class.index_changed_model_instances
  end

  it "does not track run information when exceptions are thrown" do
    ReindexRun.should_not_receive(:create!).with(entity_count: 0, notice_count: 0)
    Notice.stub(:where).and_raise(StandardError)

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

      Entity.any_instance.should_receive(:tire).once.and_return(tire_proxy)

      described_class.index_changed_model_instances
    end
  end

  context "notices" do
    it "only reindexes changed notices" do
      create(:reindex_run)

      old_entity = Timecop.travel(1.hour.ago) { create(:dmca, title: 'Old') }
      new_entity = Timecop.travel(1.hour) { create(:dmca, title: 'New') }

      Notice.any_instance.should_receive(:tire).once.and_return(tire_proxy)

      described_class.index_changed_model_instances
    end
  end

  def tire_proxy
    double('Tire proxy', update_index: true)
  end
end
