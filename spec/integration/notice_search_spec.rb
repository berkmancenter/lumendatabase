require 'spec_helper'
require 'yaml'

feature "Searching Notices" do
  include SearchHelpers

  scenario "displays search terms", search: true do
    create(:dmca, title: "The Lion King on Youtube")

    submit_search 'awesome blossom'

    expect(page).to have_css("input#search[value='awesome blossom']")
  end

  scenario "for full-text on a single model", search: true do
    notice = create(:dmca, title: "The Lion King on Youtube")
    trademark = create(:trademark, title: "Coke - it's the King thing")

    within_search_results_for("king") do
      expect(page).to have_n_results(2)
      expect(page).to have_content(notice.title)
      expect(page).to have_content(trademark.title)
      expect(page.html).to have_excerpt('King', 'The Lion', 'on Youtube')
    end
  end

  scenario "based on action taken", search: true do
    notices = [
      create(:dmca, action_taken: 'No'),
      create(:dmca, action_taken: 'Yes'),
      create(:dmca, action_taken: 'Partial'),
    ]

    notices.each do |notice|
      search_for(action_taken: notice.action_taken)

      expect(page).to have_n_results(1)
      expect(page).to have_content(notice.title)
    end
  end

  scenario "paginates properly", search: true do
    3.times do
      create(:dmca, title: "The Lion King on Youtube")
    end

    search_for(term: 'lion', page: 2, per_page: 1)

    within('.pagination') do
      expect(page).to have_css('em.current', text: 2)
      expect(page).to have_css('a[rel="next"]')
      expect(page).to have_css('a[rel="prev start"]')
    end
  end

  scenario "it does not include rescinded notices", search: true do
    notice = create(:dmca, title: "arbitrary", rescinded: true)

    expect_search_to_not_find("arbitrary", notice)
  end

  scenario "it does not include spam notices", search: true do
    notice = create(:dmca, title: "arbitrary", spam: true)

    expect_search_to_not_find("arbitrary", notice)
  end

  scenario "it does not include hidden notices", search: true do
    notice = create(:dmca, title: "arbitrary", hidden: true)

    expect_search_to_not_find("arbitrary", notice)
  end

  context "within associated models" do
    scenario "for category names", search: true do
      category = create(:category, name: "Lion King")
      notice = create(:dmca, categories: [category])

      within_search_results_for("king") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(category.name)
        expect(page).to contain_link(category_path(category))
        expect(page.html).to have_excerpt('King', 'Lion')
      end
    end

    scenario "for tags", search: true do
      notice = create(:dmca, tag_list: 'foo, bar')

      within_search_results_for("bar") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt("bar")
      end
    end

    scenario "for entities", search: true do
      notice = create(:dmca, role_names: ['sender','recipient'])

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

      notice = create(:dmca, works: [work])

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

      notice = create(:dmca, works: [work])

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

  context "changes to associated models" do
    scenario "a category is created", search: true do
      notice = create(:dmca)
      notice.categories.create!(name: "arbitrary")

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
      end
    end

    scenario "a category is destroyed", search: true do
      category = create(:category, name: "arbitrary")
      notice = create(:dmca, categories: [category])
      category.destroy

      expect_search_to_not_find("arbitrary", notice)
    end

    scenario "a category updates its name", search: true do
      category = create(:category, name: "something")
      notice = create(:dmca, categories: [category])
      category.update_attributes!(name: "arbitrary")

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
      end
    end
  end

  scenario "advanced search on multiple fields", search: true do
    create_notice_with_entities("Jim & Jon's", "Jim", "Jon")
    create_notice_with_entities("Jim & Dan's", "Jim", "Dan")
    create_notice_with_entities("Dan & Jon's", "Dan", "Jon")

    search_for(sender_name: "Jim", recipient_name: "Jon")

    expect(page).to have_content("Jim & Jon's")
    expect(page).not_to have_content("Jim & Dan's")
    expect(page).not_to have_content("Dan & Jon's")
  end

  context "sorting" do
    scenario "by date_received", search: true do
      notice = create(:dmca, title: 'Foobar First', date_received: Time.now)
      older_notice = create(
        :dmca, title: 'Foobar Last', date_received: Time.now - 10.days
      )

      search_for(title: "Foobar", sort_by: "date_received asc")
      expect(page).to have_first_notice_of(older_notice)
      expect(page).to have_last_notice_of(notice)

      search_for(title: "Foobar", sort_by: "date_received desc")
      expect(page).to have_first_notice_of(notice)
      expect(page).to have_last_notice_of(older_notice)
    end

    scenario "by relevancy", search: true do
      notice = create(:dmca, title: 'Foobar Foobar First')
      less_relevant_notice = create( :dmca, title: 'Foobar Last')

      search_for(title: "Foobar", sort_by: "relevancy asc")
      expect(page).to have_first_notice_of(less_relevant_notice)
      expect(page).to have_last_notice_of(notice)

      search_for(title: "Foobar", sort_by: "relevancy desc")
      expect(page).to have_first_notice_of(notice)
      expect(page).to have_last_notice_of(less_relevant_notice)
    end
  end

  scenario "searching with a blank parameter", search: true do
    expect { submit_search('') }.not_to raise_error
  end

  private

  def have_first_notice_of(notice)
    have_css("ol.results-list li:first-child[id='notice_#{notice.id}']")
  end

  def have_last_notice_of(notice)
    have_css("ol.results-list li:last-child[id='notice_#{notice.id}']")
  end

  def expect_search_to_not_find(term, notice)
    submit_search(term)

    expect(page).not_to have_content(notice.title)

    yield if block_given?
  end

  def have_excerpt(excerpt, prefix = nil, suffix = nil)
    include([prefix, "<em>#{excerpt}</em>", suffix].compact.join(' '))
  end

  def create_notice_with_entities(title, sender_name, recipient_name)
    sender = Entity.find_or_create_by_name(sender_name)
    recipient = Entity.find_or_create_by_name(recipient_name)

    create(:dmca, title: title).tap do |notice|
      create(
        :entity_notice_role,
        name: 'sender',
        notice: notice,
        entity: sender
      )
      create(
        :entity_notice_role,
        name: 'recipient',
        notice: notice,
        entity: recipient
      )
    end
  end

end
