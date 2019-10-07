require 'validates_automatically'

class DocumentsUpdateNotificationNotice < ApplicationRecord
  include ValidatesAutomatically

  belongs_to :notice

  validates :notice, presence: true
  validates_uniqueness_of :notice
end
