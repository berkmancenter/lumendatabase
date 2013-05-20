class FileUpload < ActiveRecord::Base
  has_attached_file :file

end
