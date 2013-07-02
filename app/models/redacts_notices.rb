class RedactsNotices
  def initialize(redactors = [RedactsPhoneNumbers])
    @redactors = redactors
  end

  def redact(notice, field_or_fields = Notice::REDACTABLE_FIELDS)
    Array(field_or_fields).each { |field| redact_field(notice, field) }
  end

  private

  attr_reader :redactors

  def redact_field(notice, field)
    if (text = notice.send(field)).present?
      new_text = redactors.inject(text) do |result, redactor|
        redactor.new(result).redacted
      end

      notice.send(:"#{field}=", new_text)
      notice.send(:"#{field}_original=", text)
    end
  end

  class RedactsRegex
    def initialize(text)
      @text = text
    end

    def redacted
      @text.gsub(regex, mask)
    end

    def mask
      '[REDACTED]'
    end

    def regex
      raise NotImplementedError, "#{self.class} did not implement #{__method__}"
    end
  end

  class RedactsPhoneNumbers < RedactsRegex
    def regex
      /(\(?\d{3}\)?.?)? # optional area code
       \d{3}[^\d]?\d{4} # phone number, optional single-char separator
      /x
    end
  end
end
