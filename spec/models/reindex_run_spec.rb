require 'spec_helper'

describe ReindexRun, type: :model do
  it 'tracks run information when no exceptions are thrown' do
    reindex_run = create(:reindex_run)
    expect(ReindexRun).to receive(:create!).and_return(reindex_run)
    now = Time.now
    allow(Time).to receive(:now).and_return(now)

    described_class.index_changed_model_instances

    expect(reindex_run.notice_count).to eq 0
    expect(reindex_run.entity_count).to eq 0

    # Why we need the extra methods after the time objects:
    # https://stackoverflow.com/questions/20403063/trouble-comparing-time-with-rspec
    expect(reindex_run.updated_at.to_s).to eq now.utc.to_s
  end

  it 'does not track run information when exceptions are thrown' do
    expect(ReindexRun)
      .not_to receive(:create!)
      .with(entity_count: 0, notice_count: 0)
    allow(Notice).to receive(:where).and_raise(StandardError)

    described_class.index_changed_model_instances
  end

  context '.last_run' do
    it 'equals the last run' do
      earliest_run = create(:reindex_run)
      latest_run = Timecop.travel(1.hour) { create(:reindex_run) }

      expect(latest_run.last_run).to eq earliest_run
    end
  end

  context 'entities' do
    it 'only reindexes changed entities' do
      create(:reindex_run)

      old_entity = Timecop.travel(1.hour.ago) { create(:entity, name: 'Old') }
      new_entity = Timecop.travel(1.hour) { create(:entity, name: 'New') }

      described_class.index_changed_model_instances

      expect(described_class.indexed?(Entity, old_entity.id)).to be false
      expect(described_class.indexed?(Entity, new_entity.id)).to be true
    end
  end

  context 'notices' do
    it 'only reindexes changed notices' do
      create(:reindex_run)

      old_entity = Timecop.travel(1.hour.ago) { create(:dmca, title: 'Old') }
      new_entity = Timecop.travel(1.hour) { create(:dmca, title: 'New') }

      described_class.index_changed_model_instances

      expect(described_class.indexed?(Notice, old_entity.id)).to be false
      expect(described_class.indexed?(Notice, new_entity.id)).to be true
    end
  end
end
