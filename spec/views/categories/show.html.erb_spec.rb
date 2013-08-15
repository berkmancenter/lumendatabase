require 'spec_helper'

describe 'categories/show.html.erb' do
  it "shows the category's name" do
    assign(:category, build(:category, name: "The Name"))
    assign(:notices, [])

    render

    expect(rendered).to include("The Name")
  end

  it "shows the category's html description" do
    category = build(:category, description: "Some *markdown*")
    assign(:category, category)
    assign(:notices, [])

    render

    expect(rendered).to include(category.description_html)
  end

  it "shows the category's relevant questions" do
    questions = build_list(:relevant_question, 3)
    assign(:category, build(:category, relevant_questions: questions))
    assign(:notices, [])

    render

    questions.each do |question|
      expect(rendered).to include(question.question)
      expect(rendered).to include(question.answer_html)
    end
  end

  context "notices" do
    it "shows a list of notices" do
      assign(:category, build(:category))
      assign(:notices, build_stubbed_list(:dmca, 2))

      render

      within('.category-notices') do
        expect(page).to have_css('article.notice', count: 2)
      end
    end

    it "does not show notices when they aren't there" do
      assign(:category, build(:category))
      assign(:notices, [])

      render

      expect(rendered).to_not have_css('.category-notices')
    end
  end
end
