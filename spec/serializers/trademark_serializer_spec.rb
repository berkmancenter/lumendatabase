require 'spec_helper'

describe TrademarkSerializer do
  it_behaves_like 'a serialized notice with base metadata', :trademark

  it "includes mark as work.description" do
    work = build(:work, description: 'Description')
    trademark = build(:trademark, works: [work], mark_registration_number: '1337')
    serialized = TrademarkSerializer.new(trademark)
    allow(serialized).to receive(:current_user).and_return(nil)
    serialized_trademark = serialized.as_json[:trademark]

    first_mark = serialized_trademark[:marks].first

    expect(first_mark['description']).to eq trademark.works.first.description
    expect(serialized_trademark).not_to have_key(:works)
    expect(serialized_trademark).to have_key(:mark_registration_number)
      .with_value('1337')
  end

  it "includes infringing_urls" do
    work = build(:work, :with_infringing_urls)
    trademark = build(:trademark, works: [work])

    serialized = TrademarkSerializer.new(trademark)
    allow(serialized).to receive(:current_user).and_return(nil)
    serialized_trademark = serialized.as_json[:trademark]
    mark = serialized_trademark[:marks].first

    expect(mark['infringing_urls']).to eq(
      work.infringing_urls_counted_by_domain.as_json
    )
  end

end
