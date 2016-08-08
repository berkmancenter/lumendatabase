require 'spec_helper'
require 'question_importer'
require 'csv'

describe QuestionImporter do
  let(:sample_file) { 'tmp/test-tQuestion.csv' }

  before do
    create(:relevant_question, question: "Question that exists?")
    create(:relevant_question, question: "Question that also exists?")
    create(
      :relevant_question,
      question: "Question for notice that does not yet exist?"
      )

    create(:dmca, original_notice_id: 1)
    create(:dmca, original_notice_id: 2)

    data = [
      [ 1, "Question that exists?" ], [ 2, "Question that also exists?" ],
      [ 2, "Question that does not exist?" ], [ 3, "Question for notice that does not yet exist?" ],
    ]

    CSV.open(sample_file, "wb") do |fh|
      fh << ["OriginalNoticeID", "Question"]
      data.each {|e| fh << e }
    end
end

after { File.unlink(sample_file) }

it "assigns relevant questions correctly" do
  QuestionImporter.new(sample_file).import

  notice_1 = Notice.where(original_notice_id: 1).first
  notice_2 = Notice.where(original_notice_id: 2).first

  expect(notice_1.relevant_questions.size).to eq(1)
  expect(notice_2.relevant_questions.size).to eq(1)
end

  it "does not clobber existing relevant questions" do
    notice = create(
      :dmca,
      original_notice_id: 3,
      relevant_questions: create_list(:relevant_question, 2)
      )

    QuestionImporter.new(sample_file).import

    expect(notice.reload.relevant_questions.size).to eq(3)
  end
end
