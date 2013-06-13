require 'spec_helper'

describe NoticeSearchResult do
  it "delegates id and title attributes to notice" do
    notice = build_stubbed(:notice)

    result = NoticeSearchResult.new(with_metadata(notice))

    expect(result.id).to eq notice.id
    expect(result.title).to eq notice.title
  end

  it "includes id, name, and parent_id from categories" do
    notice = build_stubbed(:notice, :with_categories)

    result = NoticeSearchResult.new(with_metadata(notice))

    %i( id name parent_id ).each do |attribute|
      expect(result.categories.map(&attribute)).to(
        match_array notice.categories.map(&:attribute)
      )
    end
  end

  it "includes url and description from works" do
    work = build_stubbed(:work)
    notice = build_stubbed(:notice, works: [work])

    result = NoticeSearchResult.new(with_metadata(notice))

    %i( url description ).each do |attribute|
      expect(result.works.map(&attribute)).to(
        match_array notice.works.map(&attribute)
      )
    end
  end

  it "includes url from infringing_urls" do
    work = build_stubbed(:work, :with_infringing_urls)
    notice = build_stubbed(:notice, works: [work])

    result = NoticeSearchResult.new(with_metadata(notice))

    expect(result.infringing_urls.map(&:url)).to(
      match_array notice.infringing_urls.map(&:url)
    )
  end

  it "provides access to excerpts" do
    notice = build_stubbed(:notice)
    highlight = { 'title' => ["Lion <em>King</em>"] }
    excerpts = []

    result = NoticeSearchResult.new(
      with_metadata(notice, 'highlight' => highlight)
    )

    result.with_excerpts do |excerpt|
      excerpts << excerpt
    end

    expect(excerpts).to eq(["Lion <em>King</em>"])
  end
end
