require 'validates_automatically'

class FileUpload < ActiveRecord::Base
  include ValidatesAutomatically

  attr_accessor :file_name

  validates_inclusion_of :kind, in: %w( original supporting )

  belongs_to :notice
  has_attached_file :file

  before_save :rename_file, if: ->(instance) { instance.file_name.present? }
  delegate :url, to: :file

  def file_type
    case file_content_type
    when 'application/pdf' then 'PDF'
    when /\Aimage\// then 'Image'
    else 'Document'
    end
  end

  private

  def rename_file
    self.file_file_name = file_name.gsub(/[^a-z\d\.\- ]/i, '_')
    true
  end

end
