require 'spec_helper'

describe SearchResultsProxy, type: :model do
  it 'proxies notice results to NoticeSearchResult' do
    notice = build_stubbed(:dmca)
    attributes = with_metadata(notice).merge('class_name' => 'notice')
    new_notice = Notice.new
    allow(Notice).to receive(:new).and_return(new_notice)

    expect(NoticeSearchResult).to receive(:new).with(new_notice, attributes)

    described_class.new(attributes)
  end

  it 'proxies to the default wrapper' do
    entity = build_stubbed(:entity)

    expect(Tire::Results::Item).to receive(:new).with(entity.attributes)

    router = described_class.new(entity.attributes)
  end
end
