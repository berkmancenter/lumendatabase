# frozen_string_literal: true

require 'base64'

module Lumen::Submissions::Attachment
  class InvalidAttachment < StandardError; end

  DEFAULT_KIND = 'supporting'
  DATA_URI_PATTERN = %r{\Adata:([^;,]+);base64,(.*)\z}m

  module_function

  def decode(data_uri)
    match = DATA_URI_PATTERN.match(data_uri.to_s)
    raise InvalidAttachment, 'is not a base64 data URI' unless match
    if match[1].length > 255
      raise InvalidAttachment, 'has a content type that is too long'
    end

    encoded = match[2].delete(" \n\r\t")
    [match[1], Base64.strict_decode64(encoded)]
  rescue ArgumentError
    raise InvalidAttachment, 'contains invalid base64 data'
  end

  def entries(payload)
    attributes = payload['file_uploads_attributes'] ||
                 payload[:file_uploads_attributes]
    entries = []

    case attributes
    when Array
      attributes.each_with_index do |value, index|
        entries << [index, value] if file_value(value).present?
      end
    when Hash
      attributes.each do |key, value|
        entries << [key, value] if file_value(value).present?
      end
    end

    entries
  end

  def normalize!(payload)
    entries(payload).each do |_parameter_key, attributes|
      next if (attributes['kind'] || attributes[:kind]).present?

      key = if attributes.key?(:kind) && !attributes.key?('kind')
              :kind
            else
              'kind'
            end
      attributes[key] = DEFAULT_KIND
    end

    payload
  end

  def file_value(attributes)
    attributes['file'] || attributes[:file]
  end
end
