# frozen_string_literal: true

require 'base64'

module Lumen::Submissions::Attachment
  class InvalidAttachment < StandardError; end

  DEFAULT_KIND = 'supporting'
  MAX_ATTACHMENTS = 500
  MAX_ATTACHMENT_BYTES = 25.megabytes
  MAX_TOTAL_ATTACHMENT_BYTES = 100.megabytes
  DATA_URI_PATTERN = %r{\Adata:([^;,]+);base64,(.*)\z}m

  module_function

  def decode(data_uri, max_bytes: MAX_ATTACHMENT_BYTES)
    value = data_uri.to_s
    ensure_encoded_size!(value, max_bytes)
    match = DATA_URI_PATTERN.match(value)
    raise InvalidAttachment, 'is not a base64 data URI' unless match
    if match[1].length > 255
      raise InvalidAttachment, 'has a content type that is too long'
    end

    encoded = match[2].delete(" \n\r\t")
    maximum_encoded_bytes = 4 * ((max_bytes + 2) / 3)
    raise_file_size_error!(max_bytes) if encoded.bytesize > maximum_encoded_bytes

    bytes = Base64.strict_decode64(encoded)
    validate_file_size!(bytes.bytesize, max_bytes: max_bytes)
    [match[1], bytes]
  rescue ArgumentError
    raise InvalidAttachment, 'contains invalid base64 data'
  end

  def entries(payload, max_count: nil)
    attributes = payload['file_uploads_attributes'] ||
                 payload[:file_uploads_attributes]
    entries = []
    add_entry = lambda do |key, value|
      next unless file_value(value).present?

      if max_count && entries.length >= max_count
        raise InvalidAttachment,
              "has more than #{max_count} attachments"
      end

      entries << [key, value]
    end

    case attributes
    when Array
      attributes.each_with_index do |value, index|
        add_entry.call(index, value)
      end
    when Hash
      attributes.each do |key, value|
        add_entry.call(key, value)
      end
    end

    entries
  end

  def limited_entries(payload)
    entries(payload, max_count: MAX_ATTACHMENTS)
  end

  def add_to_total_size!(total_bytes, file_bytes,
                         max_bytes: MAX_TOTAL_ATTACHMENT_BYTES)
    new_total = total_bytes + file_bytes
    return new_total if new_total <= max_bytes

    raise InvalidAttachment,
          "attachments are larger than #{human_size(max_bytes)} in total"
  end

  def validate_file_size!(file_bytes, max_bytes: MAX_ATTACHMENT_BYTES)
    return if file_bytes <= max_bytes

    raise_file_size_error!(max_bytes)
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

  def ensure_encoded_size!(value, max_bytes)
    # Standard wrapped Base64 adds less than 2% whitespace. Allow extra room
    # while rejecting oversized input before copying or decoding the payload.
    maximum_data_uri_bytes = (max_bytes * 3 / 2) + 512
    raise_file_size_error!(max_bytes) if value.bytesize > maximum_data_uri_bytes
  end

  def raise_file_size_error!(max_bytes)
    raise InvalidAttachment,
          "is larger than the #{human_size(max_bytes)} per-file limit"
  end

  def human_size(bytes)
    return "#{bytes / 1.megabyte} MB" if (bytes % 1.megabyte).zero?

    "#{bytes} bytes"
  end
end
