module Redactors
  class Redactors::SsnRedactor
    def redact(text, _options = {})
      redactor = Redactors::ContentRedactor.new(
        /\b(\d{3})\D?(\d{2})\D?(\d{4})\b/x
      )

      redactor.redact(text)
    end
  end
end
