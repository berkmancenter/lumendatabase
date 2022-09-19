require 'validates_automatically'

class Translation < ApplicationRecord
  include ValidatesAutomatically

  validates :key, presence: true
  validates_uniqueness_of :key

  after_save do
    self.class.load_all
  end

  @@translations = nil

  def self.load_all
    @@translations = Translation.all
  end

  def self.t(key)
    @@translations
      &.select { |translation| translation.key == key }
      &.first
      &.body
      &.html_safe ||
      ''
  end
end
