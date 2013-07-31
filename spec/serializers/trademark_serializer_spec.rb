require 'spec_helper'

describe TrademarkSerializer do
  it_behaves_like 'a serialized notice'

  it "includes mark as work.description" do
    work = build(:work, description: 'Description')
    trademark = build(:trademark, works: [work])
    serialized = TrademarkSerializer.new(trademark)

    mark = serialized.as_json[:trademark][:marks].first

    expect(mark).to eq trademark.works.first.description
  end
end
