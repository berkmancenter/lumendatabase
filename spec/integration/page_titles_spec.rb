require 'rails_helper'

feature 'Page titles' do
  scenario "Home" do
    visit '/'

    expect(page).to have_exact_title('Lumen')
  end

  scenario "Search", search: true do
    visit '/'
    fill_in "term", with: "search terms"
    click_on "Go"

    expect(page).to have_exact_title('Search :: Lumen')
  end

  scenario "Topics", search: true do
    topic = create(:topic)

    visit '/'
    click_on 'Topics'
    click_on topic.name

    expect(page).to have_exact_title("#{topic.name} :: Topics :: Lumen")
    expect(page).to have_heading('Topics')
  end

  scenario "Notice" do
    notice = create(:dmca)

    visit '/'
    click_on notice.title

    expect(page).to have_exact_title("#{notice.title} :: Notices :: Lumen")
  end

  scenario "Sign in" do
    visit '/'
    click_on "Sign In"

    expect(page).to have_exact_title('Sign In :: Lumen')
  end

  private

  def have_exact_title(expected_title)
    have_title(/\A#{Regexp.escape(expected_title)}\Z/)
  end
end
