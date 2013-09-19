class QuestionImporter

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def import
    CSV.foreach(@csv_file, headers: true) do |csv_row|
      notice = Notice.find_by_original_notice_id(csv_row['OriginalNoticeID'])
      question = RelevantQuestion.find_by_question(csv_row['Question'])

      if notice && question
        notice.relevant_questions << question
        notice.save!
      end
    end
  end

end
