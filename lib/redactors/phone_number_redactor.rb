module Redactors
  class Redactors::PhoneNumberRedactor
    def redact(text, _options = {})
      redactor = Redactors::ContentRedactor.new(
        /(\()?\b(\(?\d{3}\)?.?)?  # optional area code
        (\d{3}[^\d]?\d{4})|      # phone number, optional single-char separator
        (\d+[\d ]{10,16}\d+)\b   # turkish phone number
        /x
      )

      redactor.redact(text)
    end
  end
end
