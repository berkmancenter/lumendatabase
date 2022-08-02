# frozen_string_literal: true

class LumenSetting < ApplicationRecord
  validates_presence_of :name, :key, :value

  def self.get(key, cache: true)
    return nil if key.nil?

    if cache
      found_value = Lumen::SETTINGS.find { |setting| setting.key == key }&.value
      found_value = Lumen.const_get(key.upcase) if found_value.nil? && Object.const_defined?("Lumen::#{key.upcase}")
    else
      found_value = LumenSetting.where(key: key).first&.value
    end

    found_value
  end

  def self.get_i(key, cache: true)
    self.get(key, cache: cache)&.to_i
  end
end
