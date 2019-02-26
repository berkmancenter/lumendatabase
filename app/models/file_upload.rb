require 'validates_automatically'

class FileUpload < ActiveRecord::Base
  include ValidatesAutomatically

  attr_accessor :file_name

  ALLOWED_KINDS = %w[original supporting].freeze

  validates_inclusion_of :kind, in: ALLOWED_KINDS
  validates :kind, length: { maximum: 255 }

  belongs_to :notice
  has_attached_file :file,
    path: ':rails_root/paperclip/:class/:attachment/:id_partition/:style/:filename',
    url: '/:class/:attachment/:id/:id_partition/:style/:filename'

  # Paperclip did not require validations at the time this file was written,
  # and it is not now clear what filetypes were intended to be allowed.
  do_not_validate_attachment_file_type :file

  before_save :rename_file, if: ->(instance) { instance.file_name.present? }
  after_save :set_documents_requesters_notifications

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

  def set_documents_requesters_notifications
    return unless notice && kind.include?('supporting') && (new_record? || changed?)

    DocumentsUpdateNotificationNotice.create(notice: notice)
  end
end
