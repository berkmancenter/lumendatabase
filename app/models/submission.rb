require 'psuedo_model'

class Submission
  include PsuedoModel

  attr_reader :title, :subject, :body, :date_received, :source, :file,
    :tag_list, :category_ids, :works, :notice_id

  validates_presence_of :title

  def initialize(params = {})
    @title = params[:title]
    @subject = params[:subject]
    @body = params[:body]
    @date_received = params[:date_received]
    @source = params[:source]
    @file = params[:file]
    @tag_list = params[:tag_list]
    @category_ids = params[:category_ids]
    @entities = params[:entities]
    @works = params[:works]
  end

  def save
    notice = initialize_notice
    models << notice

    if file.present?
      file_upload = initialize_file_upload(notice)
      models << file_upload
    end

    AssociatesEntities.new(entities, notice, self).associate

    AssociatesWorks.new(works, notice, self).associate

    if valid? && all_models_valid? && save_all_models
      @notice_id = notice.id
    end
  end

  def available_categories
    Category.all
  end

  def models
    @models ||= []
  end

  private

  attr_reader :entities

  def initialize_notice
    notice_params = {
      title: title,
      subject: subject,
      body: body,
      date_received: date_received,
      tag_list: tag_list,
      source: source
    }

    if category_ids.present?
      notice_params[:categories] = Category.where(id: category_ids)
    end

    Notice.new(notice_params)
  end

  def initialize_file_upload(notice)
    FileUpload.new(file: file, kind: :notice, notice: notice)
  end

  def all_models_valid?
    models.all?(&:valid?)
  end

  def save_all_models
    models.all?(&:save)
  end

end
