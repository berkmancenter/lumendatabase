require 'validates_automatically'

class FileUpload < ActiveRecord::Base
  include ValidatesAutomatically

  validates_inclusion_of :kind, in: %w( original supporting )

  belongs_to :notice

  has_attached_file :file

  delegate :url, to: :file

  def file_type
    case file_content_type
    when 'application/pdf' then 'PDF'
    when /\Aimage\// then 'Image'
    else 'Document'
    end
  end

end
