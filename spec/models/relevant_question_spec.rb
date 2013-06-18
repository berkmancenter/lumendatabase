require 'spec_helper'

describe RelevantQuestion do
  context 'automatic validations' do
    it { should validate_presence_of(:question) }
    it { should validate_presence_of(:answer) }
  end

  context "#answer_html" do
    it "converts the answer from markdown" do
      question = build(:relevant_question, answer: "Some *good* markdown")

      html = question.answer_html

      expect(html).to eq "<p>Some <em>good</em> markdown</p>\n"
    end
  end
end
