class RedactsNotices
  def initialize(redactors = [RedactsPhoneNumbers.new, RedactsSSNs.new, RedactsEmail.new])
    @redactors = redactors
  end

  def redact(notice, field_or_fields = Notice::REDACTABLE_FIELDS)
    Array(field_or_fields).each { |field| redact_field(notice, field) }
  end

  def redact_all(notice_ids, field_or_fields = Notice::REDACTABLE_FIELDS)
    Notice.where(id: notice_ids).each do |notice|
      redact(notice, field_or_fields)
      notice.save
    end
  end

  private

  attr_reader :redactors

  def redact_field(notice, field)
    if (text = notice.send(field)).present?
      new_text = redactors.inject(text) do |result, redactor|
        redactor.redact(result)
      end

      notice.send(:"#{field}=", new_text)

      if notice.send(:"#{field}_original").blank?
        notice.send(:"#{field}_original=", text)
      end
    end
  end

  class RedactsContent
    def initialize(string_or_regex)
      @string_or_regex = string_or_regex
    end

    def redact(content)
      content.gsub(@string_or_regex, mask)
    end

    def mask
      '[REDACTED]'
    end
  end

  class RedactsPhoneNumbers
    def redact(text)
      redactor = RedactsContent.new(
        /(\(?\d{3}\)?.?)? # optional area code
         \d{3}[^\d]?\d{4} # phone number, optional single-char separator
        /x
      )

      redactor.redact(text)
    end
  end

  class RedactsSSNs
    def redact(text)
      redactor = RedactsContent.new(
        /\b(\d{3})\D?(\d{2})\D?(\d{4})\b/x
      )

      redactor.redact(text)
    end
  end

  class RedactsEmail
    def redact(text)
      redactor = RedactsContent.new(
        /\S+@\S+\.\S+[^.\s]/i
      )

      redactor.redact(text)
    end
  end

  class RedactsEntityName
    def initialize(name)
      match = name.strip.split(/\s/)
      ops = %w[* + - ?]
      match = match.reject { |x| ops.include? x }
      @regex_base = "(?:#{match.join('|')})(?:[^a-z]*(?:#{match.join('|')}))*"
      @regex = /#{@regex_base}/mi
    end

    def redact(text)
      return text if @regex_base.blank?
      redactor = RedactsContent.new(@regex)

      redactor.redact(text)
    end
  end
end
