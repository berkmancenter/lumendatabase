require 'spec_helper'
require 'yaml'

feature "Searching Notices" do
  include SearchHelpers

  scenario "displays search terms", search: true do
    create(:notice, title: "The Lion King on Youtube")

    submit_search 'awesome blossom'

    expect(page).to have_css("input#search[value='awesome blossom']")
  end

  scenario "for full-text on a single model", search: true do
    notice = create(:notice, title: "The Lion King on Youtube")
    trademark = create(:trademark, title: "Coke - it's the King thing")

    within_search_results_for("king") do
      expect(page).to have_n_results(2)
      expect(page).to have_content(notice.title)
      expect(page).to have_content(trademark.title)
      expect(page.html).to have_excerpt('King', 'The Lion', 'on Youtube')
    end
  end

  scenario "paginates properly", search: true do
    3.times do
      create(:notice, title: "The Lion King on Youtube")
    end
    sleep 1

    visit "/notices/search?page=2&per_page=1&term=lion"
    within('.pagination') do
      expect(page).to have_css('em.current', text: 2)
      expect(page).to have_css('a[rel="next"]')
      expect(page).to have_css('a[rel="prev start"]')
    end
  end

  scenario "it does not include rescinded notices", search: true do
    notice = create(:notice, title: "arbitrary", rescinded: true)

    expect_search_to_not_find("arbitrary", notice)
  end

  context "within associated models" do
    scenario "for category names", search: true do
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

    scenario "for tags", search: true do
      notice = create(:notice, tag_list: 'foo, bar')

      within_search_results_for("bar") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt("bar")
      end
    end

    scenario "for entities", search: true do
      notice = create(:notice, role_names: ['sender','recipient'])

      within_search_results_for(notice.recipient_name) do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(notice.recipient_name)
        expect(page.html).to have_excerpt('Entity')
      end

      within_search_results_for(notice.sender_name) do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(notice.sender_name)
        expect(page.html).to have_excerpt('Entity')
      end
    end

    scenario "for works", search: true do
      work = create(
        :work, description: "An arbitrary description"
      )

      notice = create(:notice, works: [work])

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(work.description)
        expect(page.html).to have_excerpt("arbitrary", "An", "description")
      end
    end

    scenario "for urls associated through works", search: true do
      work = create(
        :work,
        infringing_urls: [
          create(:infringing_url, url: 'http://example.com/infringing_url')
        ],
        copyrighted_urls: [
          create(:copyrighted_url, url: 'http://example.com/copyrighted_url')
        ]
      )

      notice = create(:notice, works: [work])

      within_search_results_for('infringing_url') do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt('infringing_url')
      end

      within_search_results_for('copyrighted_url') do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt('copyrighted_url')
      end
    end
  end

  context "changes to assocated models" do
    scenario "a category is created", search: true do
      notice = create(:notice)
      notice.categories.create!(name: "arbitrary")

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
      end
    end

    scenario "a category is destroyed", search: true do
      category = create(:category, name: "arbitrary")
      notice = create(:notice, categories: [category])
      category.destroy

      expect_search_to_not_find("arbitrary", notice)
    end

    scenario "a category updates its name", search: true do
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
