require 'spec_helper'

feature 'Page titles' do
  scenario "Home" do
    visit '/'

    expect(page).to have_exact_title('Chilling Effects')
  end

  scenario "Search", search: true do
    visit '/'
    fill_in "term", with: "search terms"
    click_on "Go"

    expect(page).to have_exact_title('Search :: Chilling Effects')
  end

  scenario "Blog" do
    blog_entry = create(:blog_entry, :published)

    visit '/'
    click_on 'Blog'

    # index
    expect(page).to have_exact_title('Blog :: Chilling Effects')
    expect(page).to have_heading('Blog')

    click_on blog_entry.title

    # show
    expect(page).to have_exact_title("#{blog_entry.title} :: Blog :: Chilling Effects")
    expect(page).to have_heading('Blog')
  end

  scenario "Topics", search: true do
    topic = create(:topic)

    visit '/'
    click_on 'Topics'
    click_on topic.name

    expect(page).to have_exact_title("#{topic.name} :: Topics :: Chilling Effects")
    expect(page).to have_heading('Topics')
  end

  scenario "Report Demand" do
    visit '/'
    click_on 'Report Demand'

    # select type view
    expect(page).to have_exact_title('Report Demand :: Chilling Effects')
    expect(page).to have_heading('Report Demand')

    click_on 'DMCA'

    # submission form itself
    expect(page).to have_exact_title('Dmca :: Report Demand :: Chilling Effects')
    expect(page).to have_heading('Report Demand')
  end

  scenario "Notice" do
    notice = create(:dmca)

    visit '/'
    click_on notice.title

    expect(page).to have_exact_title("#{notice.title} :: Notices :: Chilling Effects")
  end

  scenario "Sign in" do
    visit '/'
    click_on "Sign In"

    expect(page).to have_exact_title('Sign In :: Chilling Effects')
  end

  context "Pages" do
    %w( About Privacy Disclaimer Researchers ).each do |area|
      scenario area do
        visit '/'
        click_on area

        expect(page).to have_exact_title("#{area} :: Chilling Effects")
        expect(page).to have_heading(area)
      end
    end
  end

  private

  def have_exact_title(expected_title)
    have_title(/\A#{Regexp.escape(expected_title)}\Z/)
  end
end
