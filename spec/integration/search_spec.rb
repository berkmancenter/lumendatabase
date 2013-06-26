require 'spec_helper'
require 'yaml'

feature "Search", search: true do
  include SearchHelpers

  before do
    enable_live_searches
  end

  scenario "displays search terms" do
    notice = create(:notice, title: "The Lion King on Youtube")

    submit_search 'awesome blossom'

    expect(page).to have_css("input#search[value='awesome blossom']")
  end

  scenario "for full-text on a single model" do
    notice = create(:notice, title: "The Lion King on Youtube")

    within_search_results_for("king") do
      expect(page).to have_n_results(1)
      expect(page).to have_content(notice.title)
      expect(page.html).to have_excerpt('King', 'The Lion', 'on Youtube')
    end
  end

  scenario "paginates properly" do
    3.times do
      create(:notice, title: "The Lion King on Youtube")
    end
    sleep 1

    visit "/search?page=2&per_page=1&term=lion"
    within('.pagination') do
      expect(page).to have_css('em.current', text: 2)
      expect(page).to have_css('a[rel="next"]')
      expect(page).to have_css('a[rel="prev start"]')
    end
  end

  context "within associated models" do
    scenario "for category names" do
      category = create(:category, name: "Lion King")
      notice = create(:notice, categories: [category])

      within_search_results_for("king") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(category.name)
        expect(page).to contain_link(category_path(category))
        expect(page.html).to have_excerpt('King', 'Lion')
      end
    end

    scenario "for tags" do
      notice = create(:notice, tag_list: 'foo, bar')

      within_search_results_for("bar") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt("bar")
      end
    end

    scenario "for entities" do
      notice = create(:notice, role_names: ['submitter','recipient'])

      within_search_results_for(notice.recipient_name) do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(notice.recipient_name)
        expect(page.html).to have_excerpt('Entity')
      end

      within_search_results_for(notice.submitter_name) do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(notice.submitter_name)
        expect(page.html).to have_excerpt('Entity')
      end
    end

    scenario "for infringing urls" do
      work = create(:work, :with_infringing_urls)
      notice = create(:notice, works: [work])

      within_search_results_for(notice.infringing_urls.first.url) do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt('example.com')
      end
    end

    scenario "for works" do
      work = create(:work, description: "An arbitrary description")
      notice = create(:notice, works: [work])

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(work.description)
        expect(page.html).to have_excerpt("arbitrary", "An", "description")
      end

      within_search_results_for(work.url) do
        expect(page).to have_n_results(1)
        expect(page.html).to have_excerpt('example.com')
      end
    end
  end

  context "changes to assocated models" do
    scenario "a category is created" do
      notice = create(:notice)
      notice.categories.create!(name: "arbitrary")

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
      end
    end

    scenario "a category is destroyed" do
      category = create(:category, name: "arbitrary")
      notice = create(:notice, categories: [category])
      category.destroy

      expect_search_to_not_find("arbitrary", notice)
    end

    scenario "a category updates its name" do
      category = create(:category, name: "something")
      notice = create(:notice, categories: [category])
      category.update_attributes!(name: "arbitrary")

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
      end
    end
  end

  def expect_search_to_not_find(term, notice)
    submit_search(term)

    expect(page).not_to have_content(notice.title)

    yield if block_given?
  end

  def have_excerpt(excerpt, prefix = nil, suffix = nil)
    include([prefix, "<em>#{excerpt}</em>", suffix].compact.join(' '))
  end

end
