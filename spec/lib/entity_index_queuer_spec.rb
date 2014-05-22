require 'spec_helper'
require 'entity_index_queuer'

describe EntityIndexQueuer do
  context ".for" do
    it "updates updated_at for every notice associated with an entity" do
      notice = create(:dmca)

      previous_updated_at = notice.updated_at
      entity = notice.entities.first

      Timecop.travel(1.hour) { described_class.for(entity.id) }
      notice.reload

      expect(notice.updated_at.to_i).not_to eq previous_updated_at.to_i
    end
  end
end
