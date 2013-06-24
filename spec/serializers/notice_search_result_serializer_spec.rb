require 'spec_helper'

describe NoticeSearchResultSerializer do

  it_behaves_like 'a serialized notice'

  it 'includes a score attribute' do
    with_a_serialized_notice do |notice, json|
      expect(json[:score]).to eq notice.score
    end
  end

end
