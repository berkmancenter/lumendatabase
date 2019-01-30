require 'validates_automatically'

class DocumentsUpdateNotificationNotice < ActiveRecord::Base
  include ValidatesAutomatically

  validates :notice, presence: true
  validates_uniqueness_of :notice
end
