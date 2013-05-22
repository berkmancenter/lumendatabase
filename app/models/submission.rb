require 'psuedo_model'

class Submission
  include PsuedoModel

  attr_reader :title, :body, :date_sent, :file, :tag_list, :category_ids

  validates_presence_of :title

  def initialize(params = {})
    @title = params[:title]
    @body = params[:body]
    @date_sent = params[:date_sent]
    @file = params[:file]
    @tag_list = params[:tag_list]
    @category_ids = params[:category_ids]

    notice_params = params.slice(:title, :body, :date_sent, :tag_list)

    if @category_ids.present?
      notice_params[:categories] = Category.where(id: @category_ids)
    end

    notice = Notice.new(notice_params)
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

  def available_categories
    Category.all
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
