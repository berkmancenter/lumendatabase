require 'validates_automatically'

class DocumentsUpdateNotificationNotice < ApplicationRecord
  include ValidatesAutomatically

  belongs_to :notice

  validates :notice, presence: true

  before_create :make_sure_only_single_waiting_per_notice

  private

  def make_sure_only_single_waiting_per_notice
    DocumentsUpdateNotificationNotice
      .where(notice: self.notice)
      .where(status: 0)
      .destroy_all
  end
end
