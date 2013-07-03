require 'validates_automatically'

class FileUpload < ActiveRecord::Base
  include ValidatesAutomatically

  belongs_to :notice

  has_attached_file :file
end
