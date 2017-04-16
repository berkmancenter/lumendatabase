require 'validates_automatically'

class NoticeImportError < ActiveRecord::Base
  include ValidatesAutomatically
end
