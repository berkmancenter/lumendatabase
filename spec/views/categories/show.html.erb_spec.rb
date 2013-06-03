require 'spec_helper'

describe 'categories/show.html.erb' do
  it "shows the category's name" do
    assign(:category, build(:category, name: "The Name"))

    render

    expect(rendered).to include("The Name")
  end

  it "shows the category's html description" do
    category = build(:category, description: "Some *markdown*")
    assign(:category, category)

    render

    expect(rendered).to include(category.description_html)
  end

  it "shows the category's relevant questions" do
    questions = build_list(:relevant_question, 3)
    assign(:category, build(:category, relevant_questions: questions))

    render

    questions.each do |question|
      expect(rendered).to include(question.question)
      expect(rendered).to include(question.answer_html)
    end
  end
end
