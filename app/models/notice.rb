class Notice < ActiveRecord::Base

  has_many :file_uploads

  validates_presence_of :title

  def self.recent
    where('date_sent > ?', 1.week.ago).order('date_sent DESC')
  end

  def notice_file_content
    first_notice.read
  end

  private

  def first_notice
    file_uploads.notices.first || NullFileUpload.new
  end
end
