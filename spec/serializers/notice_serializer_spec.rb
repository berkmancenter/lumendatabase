require 'spec_helper'

describe NoticeSerializer do
  it_behaves_like 'a serialized notice with base metadata'

  it 'includes works' do
    with_a_serialized_notice do |notice, json|
      expect(json[:works].map { |w| w['description'] }).to eq(notice.works.map(&:description))
    end
  end

  %i|infringing_urls copyrighted_urls|.each do |url_relation|
    it "includes #{url_relation}" do
      with_a_serialized_notice do |notice, json|
        relation_json = json[:works].first[url_relation.to_s].map{|u| u['url']}
        expect(relation_json).to eq(
          notice.works.first.send(url_relation).map(&:url)
        )
        expect(relation_json.length).not_to eq 0
      end
    end
  end

  it 'includes a score attribute when the model responds to _score' do
    notice = build_notice
    allow(notice).to receive(:_score).and_return(2)
    serializer = NoticeSerializer.new(notice)

    score = serializer.as_json[:notice][:score]

    expect(score).to eq 2
  end
end
