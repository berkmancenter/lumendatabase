require 'spec_helper'

describe DMCASerializer do
  it_behaves_like 'a serialized notice with base metadata'

  it 'includes regulations' do
    dmca = build(:dmca, regulation_list: 'Article 17, DSA')
    serialized_dmca = described_class.new(dmca).as_json

    expect(serialized_dmca[:regulations]).to match_array(['Article 17', 'DSA'])
  end
end
