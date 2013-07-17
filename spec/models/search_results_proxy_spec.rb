require 'spec_helper'

describe SearchResultsProxy do
  it 'proxies notice results to NoticeSearchResult' do
    notice = build_stubbed(:notice)

    described_class.should_receive(:new).with(with_metadata(notice))

    described_class.new(with_metadata(notice))
  end

  it 'proxies to the default wrapper' do
    entity = build_stubbed(:entity)

    Tire::Results::Item.should_receive(:new).with(entity.attributes)

    router = described_class.new(entity.attributes)
  end
end
