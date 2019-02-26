require 'validates_automatically'

class DocumentsUpdateNotificationNotice < ActiveRecord::Base
  include ValidatesAutomatically

  belongs_to :notice

  validates :notice, presence: true
  validates_uniqueness_of :notice
end
