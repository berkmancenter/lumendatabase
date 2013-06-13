require 'spec_helper'

describe NoticeSearchResultSerializer do
  it 'includes base notice metadata' do
    with_serialized_notice_search_result do |notice, json|
      %i(title body date_received score).each do |att|
        expect(json[att]).to eq notice.send(att)
      end
    end
  end

  it 'includes categories' do
    with_serialized_notice_search_result do |notice, json|
      expect(json[:categories]).to eq notice.categories.map(&:name)
    end
  end

  def with_serialized_notice_search_result
    notice = create(:notice, :with_categories, role_names: ['submitter', 'recipient'])
    notice.stub(:_score).and_return(1)
    notice.stub(:score).and_return(1)

    serializer = described_class.new(notice, root: :notice)
    yield notice, serializer.as_json[:notice]
  end
end
