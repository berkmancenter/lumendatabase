require 'validates_automatically'

class FileUpload < ActiveRecord::Base
  include ValidatesAutomatically

  attr_accessor :file_name

  # attr_protected :id, :pdf_requested, :pdf_request_fulfilled
  # attr_protected :id, as: :admin

  validates_inclusion_of :kind, in: %w( original supporting )
  validates :kind, length: { maximum: 255 }

  belongs_to :notice
  has_attached_file :file,
    path: ":rails_root/paperclip/:class/:attachment/:id_partition/:style/:filename",
    url: "/:class/:attachment/:id/:id_partition/:style/:filename"

  before_save :rename_file, if: ->(instance) { instance.file_name.present? }
  delegate :url, to: :file

  def file_type
    case file_content_type
    when 'application/pdf' then 'PDF'
    when /\Aimage\// then 'Image'
    else 'Document'
    end
  end

  def request_pdf
    self.pdf_requested = true
  end

  private

  def rename_file
    self.file_file_name = file_name.gsub(/[^a-z\d\.\- ]/i, '_')
    true
  end

end