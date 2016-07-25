require 'spec_helper'

describe RelevantQuestion, type: :model do
  context 'automatic validations' do
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:answer) }
  end

  context "#answer_html" do
    it "converts the answer from markdown" do
      question = build(:relevant_question, answer: "Some *good* markdown")

      html = question.answer_html

      expect(html).to eq "<p>Some <em>good</em> markdown</p>\n"
    end
  end
end
