module Lumen::Redactors
  class EmailRedactor
    def redact(text, _options = {})
      redactor = Lumen::Redactors::ContentRedactor.new(
        /(\S+@[a-zA-z0-9-]+(\.[a-zA-z]+[^.\s])+)/i
      )

      redactor.redact(text)
    end
  end
end
