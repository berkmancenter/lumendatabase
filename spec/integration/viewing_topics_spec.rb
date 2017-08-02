require 'rails_helper'

feature "Topics" do
  include SearchHelpers
  scenario "user views a topic", search: true do
    topic = create(:topic, name: 'An awesome name')
    notice = create(:dmca, topics: [topic])
    index_changed_models

    sleep 2

    visit "/topics/#{topic.id}"

    within('section.topic-notices') do
      expect(page).to have_content notice.title
    end
  end
end
