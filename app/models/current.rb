# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :request_id, :request_url, :content_filter_context
end
