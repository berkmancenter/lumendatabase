class NoticeUpdateCall < ApplicationRecord
  before_save :default_values

  def default_values
    self.status ||= 'new'
  end
end
