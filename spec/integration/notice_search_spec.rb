require 'rails_helper'
require 'yaml'
require 'support/contain_link'

feature "Searching Notices" do
  include SearchHelpers
  include ContainLink

  scenario "displays search terms", search: true do
    create(:dmca, title: "The Lion King on Youtube")
    index_changed_models

    submit_search 'awesome blossom'

    expect(page).to have_css("input#search[value='awesome blossom']")
  end

  scenario "for full-text on a single model", search: true do
    notice = create(:dmca, title: "The Lion King on Youtube")
    trademark = create(:trademark, title: "Coke - it's the King thing")
    index_changed_models

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
    index_changed_models

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
    index_changed_models

    search_for(term: 'lion', page: 2, per_page: 1)

    within('.pagination') do
      expect(page).to have_css('.current', text: 2)
      expect(page).to have_css('a[rel="next"]')
      expect(page).to have_css('a[rel="prev"]')
    end
  end

  scenario "it does not include rescinded notices", search: true do
    notice = create(:dmca, title: "arbitrary", rescinded: true)
    index_changed_models

    expect_search_to_not_find("arbitrary", notice)
  end

  scenario "it does not include spam notices", search: true do
    notice = create(:dmca, title: "arbitrary", spam: true)
    index_changed_models

    expect_search_to_not_find("arbitrary", notice)
  end

  scenario "it does not include hidden notices", search: true do
    notice = create(:dmca, title: "arbitrary", hidden: true)
    index_changed_models

    expect_search_to_not_find("arbitrary", notice)
  end

  scenario "it does not include unpublished notices", search: true do
    notice = create(:dmca, title: "fanciest pants", published: false)
    found_notice = create(:dmca, title: "fancy pants")
    index_changed_models

    within_search_results_for("pants") do
      expect(page).to have_n_results(1)
      expect(page).to have_content(found_notice.title)
    end

    expect_search_to_not_find("fanciest pants", notice)
  end

  context "within associated models" do
    scenario "for topic names", search: true do
      topic = create(:topic, name: "Lion King")
      notice = create(:dmca, topics: [topic])
      index_changed_models

      within_search_results_for("king") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page).to have_content(topic.name)
        expect(page).to contain_link(topic_path(topic))
        expect(page.html).to have_excerpt('King', 'Lion')
      end
    end

    scenario "for tags", search: true do
      notice = create(:dmca, tag_list: 'foo, bar')
      index_changed_models

      within_search_results_for("bar") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt("bar")
      end
    end

    scenario "for entities", search: true do
      notice = create(:dmca, role_names: %w( sender principal recipient))
      index_changed_models

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

      within_search_results_for(notice.principal_name) do
        # note: principal name not shown in results
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
        expect(page.html).to have_excerpt('Entity')
      end
    end

    scenario "for works", search: true do
      work = create(
        :work, description: "An arbitrary description"
      )

      notice = create(:dmca, works: [work])
      index_changed_models

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
      index_changed_models

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
    scenario "a topic is created", search: true do
      notice = create(:dmca)
      notice.topics.create!(name: "arbitrary")
      index_changed_models

      within_search_results_for("arbitrary") do
        expect(page).to have_n_results(1)
        expect(page).to have_content(notice.title)
      end
    end

    scenario "a topic is destroyed", search: true do
      topic = create(:topic, name: "arbitrary")
      notice = create(:dmca, topics: [topic])
      topic.destroy
      index_changed_models

      expect_search_to_not_find("arbitrary", notice)
    end

    scenario "a topic updates its name", search: true do
      topic = create(:topic, name: "something")
      notice = create(:dmca, topics: [topic])
      topic.update_attributes!(name: "arbitrary")
      index_changed_models

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
    index_changed_models

    search_for(sender_name: "Jim", recipient_name: "Jon")

    expect(page).to have_content("Jim & Jon's")
    expect(page).to have_no_content("Jim & Dan's")
    expect(page).to have_no_content("Dan & Jon's")
  end

  scenario "searching with a blank parameter", search: true do
    expect { submit_search('') }.not_to raise_error
  end

  private

  def expect_search_to_not_find(term, notice)
    submit_search(term)

    expect(page).to have_no_content(notice.title)

    yield if block_given?
  end

  def have_excerpt(excerpt, prefix = nil, suffix = nil)
    include([prefix, "<em>#{excerpt}</em>", suffix].compact.join(' '))
  end

  def create_notice_with_entities(title, sender_name, recipient_name)
    sender = Entity.find_or_create_by(name: sender_name)
    recipient = Entity.find_or_create_by(name: recipient_name)

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
