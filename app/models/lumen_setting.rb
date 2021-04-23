# frozen_string_literal: true

class LumenSetting < ApplicationRecord
  validates_presence_of :name, :key, :value

  def self.get(key)
    return nil if key.nil?

    found_value = Lumen::SETTINGS.find { |setting| setting.key == key }&.value
    found_value = Lumen.const_get(key.upcase) if found_value.nil?
    found_value
  end

  def self.get_i(key)
    self.get(key)&.to_i
  end
end
