class EmailRedactor
  def redact(text, _options = {})
    redactor = ContentRedactor.new(
      /(\S+@[a-zA-z0-9-]+(\.[a-zA-z]+[^.\s])+)/i
    )

    redactor.redact(text)
  end
end
