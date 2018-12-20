class OriginalFilesController < ApplicationController
  def show
    @upload = FileUpload.where(id: params[:id]).first
    if params_match? && viewing_allowed?
      render text: File.read(file_path), content_type: @upload.file_content_type
    else
      head :not_found
    end
  end

  private

  def file_path
    @file_path ||= "#{path_params}#{".#{params[:format]}" if params[:format].present?}"
  end

  def path_params
    url_params = params[:file_path].split('/').reject { |x| x == '..' }
    File.join([Rails.root, 'paperclip', 'file_uploads', 'files',
               url_params].flatten)
  end

  def viewing_allowed?
    if @upload.kind == 'original'
      can?(:access, :original_files)
    else
      true
    end
  end

  def params_match?
    @upload && file_path && file_path ==
      @upload.file.path && File.file?(file_path)
  end
end
