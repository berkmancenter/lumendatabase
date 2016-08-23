require 'spec_helper'

describe DateRangeFilter, type: :model do

  it_behaves_like 'a search filter'

  it "properly creates facet parameters" do
    to = Time.now
    from = to - 1.month

    date_range_filter = described_class.new(:date_facet, :date_received)

    filter = date_range_filter.filter_for(
      "#{from.to_i * 1000}..#{to.to_i * 1000}"
    )

    expect(filter[0]).to eq :range
    expect(filter[1][:date_received][:to]).to be_within(1).of(to)
    expect(filter[1][:date_received][:from]).to be_within(1).of(from)
  end

end
