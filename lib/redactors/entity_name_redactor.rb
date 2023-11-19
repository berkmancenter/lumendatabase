class EntityNameRedactor
  def redact(text, options = {})
    return text unless options[:entity_name].present?

    match = options[:entity_name].gsub(/[^'0-9A-Za-z ]/, '').gsub(/[-*+?\d]/, ' ').strip.split(/\s+/)
    separator = (options[:entity_name] =~ /[a-z]/mi ? '[^a-z]' : '\s')
    @regex_base = "(?:#{match.join('|')})(?:#{separator}*(?:#{match.join('|')}))*"
    @regex = /#{@regex_base}/mi

    return text if @regex_base.blank?

    redactor = ContentRedactor.new(@regex)

    redactor.redact(text)
  end
end
