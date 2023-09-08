# frozen_string_literal: true

class Other < Notice
  REDACTION_REGEX = /google|youtube/i

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def sender_name
    if hide_identities?
      Lumen::REDACTION_MASK
    else
      super
    end
  end

  def principal_name
    if hide_identities?
      Lumen::REDACTION_MASK
    else
      super
    end
  end

  def hide_identities?
    (recipient_name =~ REDACTION_REGEX).present?
  end

  def as_indexed_json(_options)
    out = super(_options)

    if out.key?('works')
      out['works'] = out['works'].map do |work|
        work.except('description')
      end
    end

    out
  end
end
