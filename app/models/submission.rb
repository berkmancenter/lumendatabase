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

    notice = Notice.new(params.slice(:title, :body, :date_sent))

    models << notice

    if @file.present?
      models << FileUpload.new(file: @file, kind: :notice, notice: notice)
    end
  end

  def save
    if valid? && all_models_valid?
      save_all_models
    end
  end

  private

  def all_models_valid?
    models.all?(&:valid?)
  end

  def save_all_models
    models.all?(&:save)
  end

  def models
    @models ||= []
  end

end
