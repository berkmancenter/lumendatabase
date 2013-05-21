class FileUpload < ActiveRecord::Base
  belongs_to :notice

  has_attached_file :file

  def self.notices
    where(kind: :notice)
  end

  def read
    Paperclip.io_adapters.for(file).read
  end
end
