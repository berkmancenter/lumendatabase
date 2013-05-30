require 'psuedo_model'

class Submission
  include PsuedoModel

  attr_reader :title, :body, :date_received, :file, :tag_list, :category_ids

  attr_accessor :source

  validates_presence_of :title

  def initialize(params = {})
    @title = params[:title]
    @body = params[:body]
    @date_received = params[:date_received]
    @file = params[:file]
    @tag_list = params[:tag_list]
    @category_ids = params[:category_ids]
    @entities = params[:entities]
  end

  def save
    notice = initialize_notice
    models << notice

    if file.present?
      file_upload = initialize_file_upload(notice)
      models << file_upload
    end

    AssociatesEntities.new(entities, notice, self).associate_entity_models

    if valid? && all_models_valid?
      save_all_models
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
      body: body,
      date_received: date_received,
      tag_list: tag_list,
      source: source && source.to_s
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
