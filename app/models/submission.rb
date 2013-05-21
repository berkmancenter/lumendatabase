require 'psuedo_model'

class Submission
  include PsuedoModel

  attr_reader :title, :body, :date_sent, :file

  validates_presence_of :title

  def initialize(params = {})
    @title = params[:title]
    @body  = params[:body]
    @date_sent = params[:date_sent]
    @file = params[:file]

    @notice = Notice.new(params.slice(:title, :body, :date_sent))

    if @file.present?
      @file_upload = FileUpload.new(file: @file, kind: :notice)
    end
  end

  def save
    if valid? && all_models_valid?
      save_all_models
    end
  end

  private

  attr_reader :notice, :file_upload

  def all_models_valid?
    notice.valid? && (file_upload.nil? || file_upload.valid?)
  end

  def save_all_models
    if notice.save
      if file_upload
        file_upload.notice = notice
        file_upload.save
      else
        true
      end
    end
  end

end
