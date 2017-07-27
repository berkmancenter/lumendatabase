require 'rails_helper'

describe 'topics/show.html.erb' do
  it "shows the topic's name" do
    assign(:topic, build(:topic, name: "The Name"))
    assign(:notices, [])

    render

    expect(rendered).to include("The Name")
  end

  it "shows the topic's html description" do
    topic = build(:topic, description: "Some *markdown*")
    assign(:topic, topic)
    assign(:notices, [])

    render

    expect(rendered).to include(topic.description_html)
  end

  it "shows the topic's relevant questions" do
    questions = build_list(:relevant_question, 3)
    assign(:topic, build(:topic, relevant_questions: questions))
    assign(:notices, [])

    render

    questions.each do |question|
      expect(rendered).to include(question.question)
      expect(rendered).to include(question.answer_html)
    end
  end

  context "notices" do
    it "shows a list of notices" do
      assign(:topic, build(:topic))
      assign(:notices, build_stubbed_list(:dmca, 2))

      render

      expect(rendered).to have_css('.topic-notices li.notice', count: 2)
    end

    it "does not show notices when they aren't there" do
      assign(:topic, build(:topic))
      assign(:notices, [])

      render

      expect(rendered).to_not have_css('.topic-notices')
    end
  end
end
