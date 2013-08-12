require 'spec_helper'

describe TrademarkSerializer do
  it_behaves_like 'a serialized notice'

  it "includes mark as work.description" do
    work = build(:work, description: 'Description')
    trademark = build(:trademark, works: [work])
    serialized = TrademarkSerializer.new(trademark)
    serialized_trademark = serialized.as_json[:trademark]

    mark = serialized_trademark[:marks].first

    expect(mark).to eq trademark.works.first.description
    expect(serialized_trademark).not_to have_key(:works)
  end

end
