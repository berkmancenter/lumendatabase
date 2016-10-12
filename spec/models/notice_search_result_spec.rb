require 'spec_helper'

describe NoticeSearchResult, type: :model do

  it "delegates id and title attributes to notice" do
    notice = build_stubbed(:dmca)

    result = NoticeSearchResult.new(Notice.new, with_metadata(notice))

    expect(result.id).to eq notice.id
    expect(result.title).to eq notice.title
  end

  it "includes id, name, and parent_id from topics" do
    notice = build_stubbed(:dmca, :with_topics)

    result = NoticeSearchResult.new(Notice.new, with_metadata(notice))

    %i( id name parent_id ).each do |attribute|
      expect(result.topics.map(&attribute)).to(
        match_array notice.topics.map(&:attribute)
      )
    end
  end

  it "includes description from works" do
    work = build_stubbed(:work)
    notice = build_stubbed(:dmca, works: [work])

    result = NoticeSearchResult.new(Notice.new, with_metadata(notice))

    expect(result.works.map(&:description)).to(
      match_array notice.works.map(&:description)
    )
  end

  %i(infringing_urls copyrighted_urls).each do |url_relation|
    it "includes url from #{url_relation}" do
      work = build_stubbed(:work, "with_#{url_relation}".to_sym)
      notice = build_stubbed(:dmca, works: [work])

      result = NoticeSearchResult.new(Notice.new, with_metadata(notice))

      expect(result.send(url_relation).map(&:url)).to(
        match_array notice.send(url_relation).map(&:url)
      )
    end
  end

  it "provides access to excerpts" do
    notice = build_stubbed(:dmca)
    highlight = { 'title' => ["Lion <em>King</em>"] }
    excerpts = []

    result = NoticeSearchResult.new(
      Notice.new,
      with_metadata(notice, 'highlight' => highlight)
    )

    result.with_excerpts do |excerpt|
      excerpts << excerpt
    end

    expect(excerpts).to eq(["Lion <em>King</em>"])
  end
end
