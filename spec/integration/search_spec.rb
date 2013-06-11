require 'spec_helper'

feature "Search", search: true do
  before do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true

    Tire.index(Notice.index_name).delete
  end

  scenario "for full-text on a single model" do
    notice = create(:notice, title: "The Lion King on Youtube")

    expect_search_to_find("king", notice) do
      expect(page.html).to have_excerpt('King', 'The Lion', 'on Youtube')
    end
  end

  context "within associated models" do
    scenario "for category names" do
      category = create(:category, name: "Lion King")
      notice = create(:notice, categories: [category])

      expect_search_to_find("king", notice) do
        expect(page).to have_content(category.name)
        expect(page).to contain_link(category_path(category))
        expect(page.html).to have_excerpt('King', 'Lion')
      end
    end

    scenario "for tags" do
      notice = create(:notice, tag_list: 'foo, bar')

      expect_search_to_find("bar", notice) do
        expect(page.html).to have_excerpt("bar")
      end
    end

    scenario "for entities" do
      notice = create(:notice, role_names: ['submitter','recipient'])

      expect_search_to_find(notice.recipient_name, notice) do
        expect(page).to have_content(notice.recipient_name)
        expect(page.html).to have_excerpt('Entity')
      end

      expect_search_to_find(notice.submitter_name, notice) do
        expect(page).to have_content(notice.submitter_name)
        expect(page.html).to have_excerpt('Entity')
      end
    end

    scenario "for infringing urls" do
      work = create(:work, :with_infringing_urls)
      notice = create(:notice, works: [work])

      expect_search_to_find(notice.infringing_urls.first.url, notice) do
        expect(page.html).to have_excerpt('example.com')
      end
    end
  end

  def expect_search_to_find(term, notice)
    sleep 1 # required for indexing to complete

    visit '/'

    fill_in 'search', with: term
    click_on 'submit'

    expect(page).to have_css('.result', count: 1)
    within('.result') do
      expect(page).to have_content(notice.title)
      yield if block_given?
    end
  end

  def have_excerpt(excerpt, prefix = nil, suffix = nil)
    include([prefix, "<em>#{excerpt}</em>", suffix].compact.join(' '))
  end
end
